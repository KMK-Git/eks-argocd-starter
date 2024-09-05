// General variables
variable "argocd_domainname" {
  type        = string
  description = "Domain used for ArgoCD"
  default     = "kaustubhk.com"
}

variable "argocd_hostname_prefix" {
  type        = string
  description = "Prefix added to domain used for ArgoCD"
  default     = "argocd-eks"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names"
  default     = "argocdstarter"
}

variable "repository_branch" {
  type        = string
  description = "Repository branch used as target for ArgoCD Apps"
  default     = "main"
}

variable "repository_url" {
  type        = string
  description = "Repository url where ArgoCD Apps are stored"
  default     = ""
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
  default     = ["us-east-1a", "us-east-1b"]
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

variable "vpc_cidr" {
  type        = string
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_private_cidrs" {
  type        = list(string)
  description = "CIDRs for VPC private subnets"
  default     = []
}

variable "vpc_public_cidrs" {
  type        = list(string)
  description = "CIDRs for VPC public subnets"
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

// Cluster variables
variable "cluster_version" {
  type        = string
  description = "Kubernetes <major>.<minor> version to use for the EKS cluster"
  default     = "1.30"
}

variable "publicly_accessible_cluster" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = true
}

variable "publicly_accessible_cluster_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = ["0.0.0.0/0"]
}
