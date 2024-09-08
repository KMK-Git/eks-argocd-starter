variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "attach_load_balancer_controller_policy" {
  description = "Determines whether to attach the Load Balancer Controller policy to the role"
  type        = bool
  default     = false
}

variable "attach_external_dns_policy" {
  description = "Determines whether to attach the External DNS IAM policy to the role"
  type        = bool
  default     = false
}

variable "dynamic_chart_options" {
  description = "List of additional options that need to be passed to service account Helm chart"
  type = list(object({
    name  = number
    value = number
  }))
  default = []
}

variable "namespace" {
  description = "Namespace in which service account will be created"
  type        = string
  default     = "kube-system"
}
variable "name_prefix" {
  description = "Prefix used for resource names"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN for OIDC provider associated with EKS cluster"
  type        = string
}

variable "partition" {
  description = "AWS partition"
  type        = string
}

variable "role_name" {
  description = "Name of IAM role created for service account"
  type        = string
}

variable "service_account_name" {
  description = "Name for service account"
  type        = string
}
