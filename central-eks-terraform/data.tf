data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_vpc" "vpc" {
  tags = {
    "Name" = "${var.name_prefix}vpc"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.vpc.tags.Name}-public-*"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.vpc.tags.Name}-private-*"]
  }
}

data "aws_subnets" "private_az_specific" {
  for_each = toset(var.availability_zones)
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.vpc.tags.Name}-private-${each.key}"]
  }
}
