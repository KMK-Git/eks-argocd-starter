// General variables
variable "central_cluster_name" {
  type        = string
  description = "Name used for central cluster"
  default     = "argocdstartercluster"
}


variable "central_name_prefix" {
  type        = string
  description = "Prefix used for central cluster resource names"
  default     = "argocdstarter"
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "enable_external_dns" {
  description = "Enable external-dns operator add-on"
  type        = bool
  default     = false
}

variable "enable_metrics_server" {
  description = "Enable metrics server add-on"
  type        = bool
  default     = true
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names"
  default     = "argocdmanagedstarter"
}

variable "route53_zone_names" {
  type        = list(string)
  description = "List of names of route 53 zones which are managed by ExternalDNS, if enabled"
  default     = []
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
    cluster_support_type              = string
  })
  description = "Details of Managed EKS cluster"
  default = {
    cluster_name                      = "argocdmanagedcluster"
    cluster_version                   = "1.30"
    publicly_accessible_cluster       = true
    publicly_accessible_cluster_cidrs = ["0.0.0.0/0"]
    cluster_support_type              = "STANDARD"
  }
}

variable "restrict_instance_metadata" {
  type        = bool
  description = "Restrict pods from accesssing node instance metadata endpoint"
  default     = true
}

variable "sso_cluster_admin_role_name" {
  type        = string
  description = "Name of AWS IAM Identity Center role added as cluster admin"
  default     = "AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"
}

// ArgoCD project variables

variable "create_baseapp" {
  type        = bool
  description = "Set to true to create an ArgoCD app. This should be used as a base app in an app of apps pattern"
  default     = false
}

variable "app_repository_url" {
  type        = string
  description = "URL for app repository"
  default     = ""
}

variable "app_repository_branch" {
  type        = string
  description = "Branch for app repository"
  default     = ""
}

variable "app_repository_path" {
  type        = string
  description = "Path for app repository"
  default     = ""
}
