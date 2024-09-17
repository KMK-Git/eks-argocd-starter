variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "aws_partition" {
  type        = string
  description = "AWS account partition"
}

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

variable "oidc_provider_arn" {
  type        = string
  description = "ARN pf EKS Cluster OIDC provider"
}
