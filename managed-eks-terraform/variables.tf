// General variables
variable "deploy_lb_controller" {
  type        = bool
  description = "True to deploy Load Balancer controller"
}

variable "deploy_external_dns" {
  type        = bool
  description = "True to deploy ExternalDNS controller"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names"
  default     = "argocdmanagedstarter"
}

variable "tags" {
  type        = map(string)
  description = "Default tags for all resources"
  default = {
    Environment = "Sample"
  }
}

// Networking variables

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cluster_ip_family" {
  description = "The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created"
  type        = string
  default     = "ipv4"
}

variable "eks_vpc_cni_custom_networking" {
  description = "Use custom networking configuration for AWS VPC CNI"
  type        = bool
  default     = true
}

// Cluster variables

variable "managed_eks_cluster" {
  type = object({
    cluster_name                      = string
    cluster_version                   = string
    publicly_accessible_cluster       = bool
    publicly_accessible_cluster_cidrs = list(string)
  })
  description = "Details of Managed EKS cluster"
  default = {
    cluster_name                      = "argocdmanagedcluster"
    cluster_version                   = "1.30"
    publicly_accessible_cluster       = true
    publicly_accessible_cluster_cidrs = ["0.0.0.0/0"]
  }
}

variable "sso_cluster_admin_role_name" {
  type        = string
  description = "Name of AWS IAM Identity Center role added as cluster admin"
  default     = "AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"
}
