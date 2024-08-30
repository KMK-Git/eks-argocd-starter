locals {
  cluster_name  = "${var.name_prefix}cluster"
  az_subnet_map = zipmap(var.availability_zones, slice(module.vpc.public_subnets, length(var.availability_zones) % length(module.vpc.public_subnets), length(module.vpc.public_subnets)))
}
