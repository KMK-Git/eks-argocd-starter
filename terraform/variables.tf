// General variables
variable "argocd_domainname" {
  type        = string
  description = "Domain used for ArgoCD"
  default     = "eks.kaustubhk.com"
}

variable "argocd_hostname_prefix" {
  type        = string
  description = "Prefix added to domain used for ArgoCD"
  default     = "argocd"
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
  default     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

variable "vpc_public_cidrs" {
  type        = list(string)
  description = "CIDRs for VPC public subnets"
  default     = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20", "10.0.112.0/20"]
}

// Cluster variables
variable "application_eks_clusters" {
  type = list(object({
    cluster_name                      = string
    cluster_version                   = string
    publicly_accessible_cluster       = bool
    publicly_accessible_cluster_cidrs = list(string)
  }))
  description = "Details of EKS clusters managed by Central EKS cluster"
  default     = []
}

variable "central_eks_cluster" {
  type = object({
    cluster_name                      = string
    cluster_version                   = string
    publicly_accessible_cluster       = bool
    publicly_accessible_cluster_cidrs = list(string)
  })
  description = "Details of Central EKS cluster"
  default = {
    cluster_name                      = "argocdstartercluster"
    cluster_version                   = "1.30"
    publicly_accessible_cluster       = true
    publicly_accessible_cluster_cidrs = ["0.0.0.0/0"]
  }
}
