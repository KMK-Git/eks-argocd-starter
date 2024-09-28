module "managed_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435"

  cluster_name    = var.managed_eks_cluster.cluster_name
  cluster_version = var.managed_eks_cluster.cluster_version

  cluster_endpoint_public_access       = var.managed_eks_cluster.publicly_accessible_cluster
  cluster_endpoint_public_access_cidrs = var.managed_eks_cluster.publicly_accessible_cluster ? var.managed_eks_cluster.publicly_accessible_cluster_cidrs : null

  cluster_addons = {
    coredns = {
      most_recent = true
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
  cluster_upgrade_policy = {
    support_type = var.managed_eks_cluster.cluster_support_type
  }
  # Allow central cluster to access api endpoint
  cluster_security_group_additional_rules = {
    "central_cluster_to_managed_cluster" = {
      description              = "cluster api access"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = data.aws_security_group.central_cluster_node.id
    }
  }
}

data "aws_route53_zone" "route53_zones" {
  for_each     = toset(var.route53_zone_names)
  name         = each.value
  private_zone = false
}

module "eks_blueprints_addons" {
  depends_on = [module.managed_eks]
  source     = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=a9963f4a0e168f73adb033be594ac35868696a91"

  cluster_name      = module.managed_eks.cluster_name
  cluster_endpoint  = module.managed_eks.cluster_endpoint
  cluster_version   = module.managed_eks.cluster_version
  oidc_provider_arn = module.managed_eks.oidc_provider_arn

  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  enable_metrics_server               = var.enable_metrics_server
  enable_external_dns                 = var.enable_external_dns
  external_dns_route53_zone_arns      = var.enable_external_dns ? data.aws_route53_zone.route53_zones[*].arn : []
}

resource "aws_iam_role" "argocd_admin_role" {
  name = "${var.name_prefix}ArgoCDAdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
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

resource "aws_iam_role_policy_attachment" "argocd_admin_assume_role_policy_attachment" {
  role       = data.aws_iam_role.argocd_service_account.name
  policy_arn = aws_iam_policy.argocd_admin_assume_role_policy.arn
}

resource "helm_release" "argocdmanagedcluster" {
  provider         = helm.argocdcluster
  depends_on       = [module.managed_eks, aws_iam_role_policy_attachment.argocd_admin_assume_role_policy_attachment]
  name             = module.managed_eks.cluster_name
  chart            = "${path.module}/../charts/argocdmanagedcluster"
  namespace        = "argocd"
  version          = "0.1.0"
  create_namespace = true
  set {
    name  = "cluster.name"
    value = module.managed_eks.cluster_name
  }
  set {
    name  = "cluster.role_arn"
    value = aws_iam_role.argocd_admin_role.arn
  }
  set {
    name  = "cluster.ca_data"
    value = module.managed_eks.cluster_certificate_authority_data
  }
  set {
    name  = "cluster.arn"
    value = module.managed_eks.cluster_arn
  }
  set {
    name  = "cluster.endpoint"
    value = module.managed_eks.cluster_endpoint
  }
}

resource "helm_release" "argocdbaseapp" {
  count            = var.create_baseapp ? 1 : 0
  provider         = helm.argocdcluster
  depends_on       = [helm_release.argocdmanagedcluster]
  name             = "${module.managed_eks.cluster_name}app"
  chart            = "${path.module}/../charts/argocdbaseapp"
  namespace        = "argocd"
  version          = "0.0.1"
  create_namespace = true
  set {
    name  = "repository.url"
    value = var.app_repository_url
  }

  set {
    name  = "repository.branch"
    value = var.app_repository_branch
  }

  set {
    name  = "repository.branch"
    value = var.app_repository_path
  }

  set {
    name  = "destination.url"
    value = module.managed_eks.cluster_endpoint
  }
}
