module "controller_role" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-role-for-service-accounts-eks?ref=89fe17a6549728f1dc7e7a8f7b707486dfb45d89"

  role_name = var.role_name

  attach_load_balancer_controller_policy = var.attach_load_balancer_controller_policy
  attach_external_dns_policy             = var.attach_external_dns_policy
  policy_name_prefix                     = var.name_prefix

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = [for service_account_name in var.service_account_names : "${var.namespace}:${service_account_name}"]
    }
  }
}

resource "helm_release" "serviceaccount" {
  for_each         = toset(var.service_account_names)
  name             = each.key
  chart            = "${path.module}/../../charts/eksserviceaccount"
  namespace        = var.namespace
  version          = "0.1.0"
  create_namespace = false

  set {
    name  = "aws.account.id"
    value = var.account_id
  }

  set {
    name  = "aws.account.partition"
    value = var.partition
  }

  set {
    name  = "aws.role_name"
    value = var.role_name
  }

  set {
    name  = "serviceAccount.name"
    value = each.key
  }

  dynamic "set" {
    for_each = var.dynamic_chart_options
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }
}
