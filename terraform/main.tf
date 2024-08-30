/*
References:
https://aws-ia.github.io/terraform-aws-eks-blueprints/patterns/karpenter-mng/
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/karpenter/main.tf
*/

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=e226cc15a7b8f62fd0e108792fea66fa85bcb4b9"

  name = "${var.name_prefix}vpc"
  cidr = var.vpc_cidr

  azs                     = var.availability_zones
  private_subnets         = var.vpc_private_cidrs
  public_subnets          = var.vpc_public_cidrs
  map_public_ip_on_launch = true

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway   = false
}


module "eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = var.publicly_accessible_cluster
  cluster_endpoint_public_access_cidrs = var.publicly_accessible_cluster_cidrs

  cluster_addons = {
    coredns = {
      before_compute = true
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {
      before_compute = true
    }
    vpc-cni = {
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        eniConfig = var.eks_vpc_cni_custom_networking ? {
          create  = true
          region  = data.aws_region.current.name
          subnets = { for az, subnet_id in local.az_subnet_map : az => { securityGroups : [module.eks.node_security_group_id], id : subnet_id } }
        } : null
        env = {
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = var.eks_vpc_cni_custom_networking ? "true" : "false"
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
      } })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = slice(module.vpc.public_subnets, 0, length(var.availability_zones))
  control_plane_subnet_ids = slice(module.vpc.public_subnets, 0, length(var.availability_zones))
  cluster_ip_family        = var.cluster_ip_family

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    coreaddons = {
      instance_types = ["m5.large"]

      min_size     = 2
      max_size     = 2
      desired_size = 2

      subnet_ids = slice(module.vpc.public_subnets, length(var.availability_zones) % length(module.vpc.public_subnets), length(module.vpc.public_subnets))

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "coreaddons" = "true"
      }

      taints = {
        # Only critical addon pods should run on nodes not managed by Karpenter
        coreaddons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }
  # node_security_group_tags = {
  #   # NOTE - if creating multiple security groups with this module, only tag the
  #   # security group that Karpenter should utilize with the following tag
  #   # (i.e. - at most, only one security group should have this tag in your account)
  #   "karpenter.sh/discovery" = local.cluster_name
  # }
  access_entries = {
    # One access entry with a policy associated
    ssorole = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "karpenter" {
  source       = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/karpenter?ref=c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435"
  cluster_name = module.eks.cluster_name

  enable_v1_permissions           = true
  enable_pod_identity             = true
  create_pod_identity_association = true
  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "helm_release" "argocd" {
  depends_on       = [module.eks]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.4.5"
  create_namespace = true
  values           = [file("${path.module}/helmvalues/argocd.yaml")]
}

resource "helm_release" "argocd_baseapp" {
  depends_on       = [helm_release.argocd]
  name             = "argocdbaseapp"
  chart            = "${path.module}/../charts/baseapp"
  namespace        = "argocd"
  version          = "0.1.1"
  create_namespace = true
  set {
    name  = "repository.url"
    value = var.repository_url
  }

  set {
    name  = "repository.branch"
    value = var.repository_branch
  }

  set {
    name  = "repository.path"
    value = "apps/allapps"
  }
}
