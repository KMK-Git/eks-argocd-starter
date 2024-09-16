variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names"
  default     = "argocdstarter"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "use_managed_nat" {
  description = "Use AWS managed NAT. If false, fck-nat is used instead"
  type        = bool
  default     = false
}

variable "use_ha_nat" {
  description = "Use NAT in HA mode"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_private_cidrs" {
  type        = list(string)
  description = "CIDRs for VPC private subnets"
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20", ]
}

variable "vpc_public_cidrs" {
  type        = list(string)
  description = "CIDRs for VPC public subnets"
  default     = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20", "10.0.176.0/20"]
}

variable "tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default = {
    Environment = "Sample"
  }
}
