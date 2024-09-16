locals {
  az_subnet_map   = zipmap(var.availability_zones, slice(data.aws_subnets.private.ids, length(var.availability_zones) % length(data.aws_subnets.private.ids), length(data.aws_subnets.private.ids)))
  argocd_hostname = "${var.argocd_hostname_prefix}.${var.argocd_domainname}"
}
