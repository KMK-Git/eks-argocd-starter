locals {
  cni_az_subnet_map  = { for availability_zone in var.availability_zones : availability_zone => data.aws_subnets.private[availability_zone].ids[1 % length(data.aws_subnets.private[availability_zone].ids)] }
  public_subnet_ids  = [for availability_zone in var.availability_zones : data.aws_subnets.public[availability_zone].ids[0]]
  private_subnet_ids = [for availability_zone in var.availability_zones : data.aws_subnets.private[availability_zone].ids[0]]
}
