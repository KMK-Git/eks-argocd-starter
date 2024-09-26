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

  enable_nat_gateway     = var.use_managed_nat
  single_nat_gateway     = var.use_managed_nat ? !var.use_ha_nat : null
  one_nat_gateway_per_az = var.use_managed_nat ? var.use_ha_nat : null
}

module "fcknat" {
  count     = var.use_managed_nat ? 0 : (var.use_ha_nat ? length(var.availability_zones) : 1)
  source    = "git::https://github.com/RaJiska/terraform-aws-fck-nat.git?ref=9377bf9247c96318b99273eb2978d1afce8cf0eb"
  name      = "fck-nat"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[count.index]
  ha_mode   = true # Enables high-availability mode

  update_route_tables = true
  route_tables_ids    = { for idx, route_table_id in module.vpc.private_route_table_ids : idx => route_table_id }
}
