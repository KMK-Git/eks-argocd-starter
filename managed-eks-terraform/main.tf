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
    # One access entry with a policy associated
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
  }
}

module "aws_lb_controller_service_account" {
  depends_on                             = [module.managed_eks]
  source                                 = "../modules/eksserviceaccount"
  account_id                             = data.aws_caller_identity.current.account_id
  attach_load_balancer_controller_policy = true
  dynamic_chart_options = [
    {
      name  = "serviceAccount.labels.app\\.kubernetes\\.io/component"
      value = "controller"
    },
    {
      name  = "serviceAccount.labels.app\\.kubernetes\\.io/name"
      value = "aws-load-balancer-controller"
    }
  ]
  name_prefix           = var.name_prefix
  oidc_provider_arn     = module.managed_eks.oidc_provider_arn
  partition             = data.aws_partition.current.partition
  role_name             = "${var.name_prefix}LBControllerRole"
  service_account_names = ["aws-load-balancer-controller"]
}

module "external_dns_service_account" {
  depends_on                 = [module.managed_eks]
  source                     = "../modules/eksserviceaccount"
  account_id                 = data.aws_caller_identity.current.account_id
  attach_external_dns_policy = true
  name_prefix                = var.name_prefix
  oidc_provider_arn          = module.managed_eks.oidc_provider_arn
  partition                  = data.aws_partition.current.partition
  role_name                  = "${var.name_prefix}ExternalDNSRole"
  service_account_names      = ["external-dns"]
}
