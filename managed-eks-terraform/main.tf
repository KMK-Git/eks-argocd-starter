/*
References:
https://aws-ia.github.io/terraform-aws-eks-blueprints/patterns/karpenter-mng/
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/karpenter/main.tf
*/




module "managed_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435"

  cluster_name    = var.managed_eks_cluster.cluster_name
  cluster_version = var.managed_eks_cluster.cluster_version

  cluster_endpoint_public_access       = var.managed_eks_cluster.publicly_accessible_cluster
  cluster_endpoint_public_access_cidrs = var.managed_eks_cluster.publicly_accessible_cluster ? var.managed_eks_cluster.publicly_accessible_cluster_cidrs : null

  cluster_addons = {
    coredns = {
      before_compute = true
      most_recent    = true
    }
    eks-pod-identity-agent = {
      before_compute = true
      most_recent    = true
    }
    kube-proxy = {
      before_compute = true
      most_recent    = true
    }
    vpc-cni = {
      before_compute = true
      most_recent    = true
      configuration_values = jsonencode({
        eniConfig = var.eks_vpc_cni_custom_networking ? {
          create  = true
          region  = data.aws_region.current.name
          subnets = { for az, subnet_id in local.cni_az_subnet_map : az => { securityGroups : [module.managed_eks.node_security_group_id], id : subnet_id } }
        } : null
        env = {
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = var.eks_vpc_cni_custom_networking ? "true" : "false"
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
      } })
    }
  }

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.public_subnet_ids
  cluster_ip_family        = var.cluster_ip_family

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    nodegroup = {
      instance_types = ["m6i.large"]

      min_size     = 3
      max_size     = 3
      desired_size = 3

      subnet_ids = local.private_subnet_ids
    }
  }
  access_entries = {
    ssorole = {
      kubernetes_groups = []
      principal_arn     = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/${var.sso_cluster_admin_role_name}"

      policy_associations = {
        example = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    argocdrole = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.argocd_admin_role.arn

      policy_associations = {
        example = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "clusterinfra" {
  depends_on           = [module.managed_eks]
  source               = "../modules/clusterinfra"
  account_id           = data.aws_caller_identity.current.account_id
  aws_partition        = data.aws_partition.current.partition
  deploy_lb_controller = var.deploy_lb_controller
  deploy_external_dns  = var.deploy_external_dns
  name_prefix          = var.name_prefix
  oidc_provider_arn    = module.managed_eks.oidc_provider_arn
}

resource "aws_iam_role" "argocd_admin_role" {
  name = "${var.name_prefix}ArgoCDAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_iam_role.argocd_service_account.arn
        }
      },
    ]
  })
}

resource "aws_iam_policy" "argocd_admin_assume_role_policy" {
  name        = "${var.name_prefix}ArgoCDAdminAssumeRole"
  description = "Allow ArgoCD service account to assume cluster admin role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.argocd_admin_role.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = data.aws_iam_role.argocd_service_account.arn
  policy_arn = aws_iam_policy.argocd_admin_assume_role_policy.arn
}
