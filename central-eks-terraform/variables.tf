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
