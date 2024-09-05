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
    nodegroup = {
      instance_types = ["m6i.large"]

      min_size     = 3
      max_size     = 3
      desired_size = 3

      subnet_ids = slice(module.vpc.public_subnets, length(var.availability_zones) % length(module.vpc.public_subnets), length(module.vpc.public_subnets))
    }
  }
  access_entries = {
    # One access entry with a policy associated
    ssorole = {
      kubernetes_groups = []
      principal_arn     = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"

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

resource "aws_acm_certificate" "argocd" {
  domain_name       = local.argocd_hostname
  validation_method = "DNS"
}

data "aws_route53_zone" "argocd" {
  name         = var.argocd_domainname
  private_zone = false
}

resource "aws_route53_record" "argocd" {
  for_each = {
    for dvo in aws_acm_certificate.argocd.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.argocd.zone_id
}

resource "aws_acm_certificate_validation" "argocd" {
  certificate_arn         = aws_acm_certificate.argocd.arn
  validation_record_fqdns = [for record in aws_route53_record.argocd : record.fqdn]
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
  version          = "0.1.4"
  create_namespace = true
  set {
    name  = "repository.url"
    value = var.repository_url
  }

  set {
    name  = "repository.branch"
    value = var.repository_branch
  }
}

resource "helm_release" "tfdependentresources" {
  depends_on = [helm_release.argocd_baseapp, aws_acm_certificate_validation.argocd, module.aws_lb_controller_role, module.external_dns_role]
  name       = "tfdependentresources"
  chart      = "${path.module}/../charts/tfdependentresources"
  namespace  = "kube-system"
  version    = "0.8.0"

  set {
    name  = "aws.account.id"
    value = data.aws_caller_identity.current.account_id
  }

  set {
    name  = "aws.account.partition"
    value = data.aws_partition.current.partition
  }

  set {
    name  = "aws.lb_role_name"
    value = "${var.name_prefix}LBControllerRole"
  }

  set {
    name  = "aws.external_dns_role_name"
    value = "${var.name_prefix}ExternalDNSRole"
  }

  set {
    name  = "argocdlb.hostname"
    value = local.argocd_hostname
  }

  set {
    name  = "argocdlb.certificatearn"
    value = aws_acm_certificate.argocd.arn
  }

  set {
    name  = "argocdlb.subnetlist"
    value = join("\\,", slice(module.vpc.public_subnets, 0, length(var.availability_zones)))
  }
}

module "aws_lb_controller_role" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=89fe17a6549728f1dc7e7a8f7b707486dfb45d89"

  role_name = "${var.name_prefix}LBControllerRole"

  attach_load_balancer_controller_policy = true
  policy_name_prefix                     = var.name_prefix

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

module "external_dns_role" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=89fe17a6549728f1dc7e7a8f7b707486dfb45d89"

  role_name = "${var.name_prefix}ExternalDNSRole"

  attach_external_dns_policy = true
  policy_name_prefix         = var.name_prefix

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
}
