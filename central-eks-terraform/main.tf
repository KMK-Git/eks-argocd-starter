module "central_eks" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks.git?ref=c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435"

  cluster_name    = var.central_eks_cluster.cluster_name
  cluster_version = var.central_eks_cluster.cluster_version

  cluster_endpoint_public_access       = var.central_eks_cluster.publicly_accessible_cluster
  cluster_endpoint_public_access_cidrs = var.central_eks_cluster.publicly_accessible_cluster ? var.central_eks_cluster.publicly_accessible_cluster_cidrs : null

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
          subnets = { for az, subnet_id in local.cni_az_subnet_map : az => { securityGroups : [module.central_eks.node_security_group_id], id : subnet_id } }
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
  }
  cluster_upgrade_policy = {
    support_type = var.central_eks_cluster.cluster_support_type
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

module "controller_role" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=89fe17a6549728f1dc7e7a8f7b707486dfb45d89"

  role_name = "${var.name_prefix}ManagementRole"

  policy_name_prefix = var.name_prefix

  oidc_providers = {
    main = {
      provider_arn               = module.central_eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-application-controller", "argocd:argocd-server"]
    }
  }
}

module "eks_blueprints_addons" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git?ref=a9963f4a0e168f73adb033be594ac35868696a91"

  cluster_name      = module.central_eks.cluster_name
  cluster_endpoint  = module.central_eks.cluster_endpoint
  cluster_version   = module.central_eks.cluster_version
  oidc_provider_arn = module.central_eks.oidc_provider_arn

  enable_argocd                       = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_external_dns                 = true
  external_dns_route53_zone_arns      = [data.aws_route53_zone.argocd.arn]
  argocd = {
    chart_version = "7.4.5"
    values        = [file("${path.module}/helmvalues/argocd.yaml")]
    set = [
      {
        name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = module.controller_role.iam_role_arn
      },
      {
        name  = "server.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = module.controller_role.iam_role_arn
      }
    ]
  }
}

# resource "helm_release" "argocd_baseapp" {
#   depends_on       = [helm_release.argocd]
#   name             = "argocdbaseapp"
#   chart            = "${path.module}/../charts/argocdbaseapp"
#   namespace        = "argocd"
#   version          = "0.1.4"
#   create_namespace = true
#   set {
#     name  = "repository.url"
#     value = var.repository_url
#   }

#   set {
#     name  = "repository.branch"
#     value = var.repository_branch
#   }
# }

resource "helm_release" "argocdingress" {
  depends_on = [helm_release.argocd, aws_acm_certificate_validation.argocd, module.eks_blueprints_addons]
  name       = "argocdingress"
  chart      = "${path.module}/../charts/argocdingress"
  namespace  = "kube-system"
  version    = "0.9.0"

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
    value = join("\\,", local.public_subnet_ids)
  }
}
