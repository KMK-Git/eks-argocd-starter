locals {
  az_subnet_map   = { for availability_zone in var.availability_zones : availability_zone => data.aws_subnets.private_az_specific[availability_zone].ids[0] }
  argocd_hostname = "${var.argocd_hostname_prefix}.${var.argocd_domainname}"
}
