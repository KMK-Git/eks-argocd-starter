module "aws_lb_controller_service_account" {
  count                                  = var.deploy_lb_controller ? 1 : 0
  source                                 = "../eksserviceaccount"
  account_id                             = var.account_id
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
  oidc_provider_arn     = var.oidc_provider_arn
  partition             = var.aws_partition
  role_name             = "${var.name_prefix}LBControllerRole"
  service_account_names = ["aws-load-balancer-controller"]
}

module "external_dns_service_account" {
  count                      = var.deploy_external_dns ? 1 : 0
  source                     = "../eksserviceaccount"
  account_id                 = var.account_id
  attach_external_dns_policy = true
  name_prefix                = var.name_prefix
  oidc_provider_arn          = var.oidc_provider_arn
  partition                  = var.aws_partition
  role_name                  = "${var.name_prefix}ExternalDNSRole"
  service_account_names      = ["external-dns"]
}
