<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.15.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd_pod_identity"></a> [argocd\_pod\_identity](#module\_argocd\_pod\_identity) | git::https://github.com/terraform-aws-modules/terraform-aws-eks-pod-identity | f39ff40fd4f45d61dda0b1a26cb82e1a005e2417 |
| <a name="module_central_eks"></a> [central\_eks](#module\_central\_eks) | git::https://github.com/terraform-aws-modules/terraform-aws-eks.git | c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git | a9963f4a0e168f73adb033be594ac35868696a91 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [helm_release.argocdingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [time_sleep.wait_lb_controller_deployment](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_domainname"></a> [argocd\_domainname](#input\_argocd\_domainname) | Domain used for ArgoCD | `string` | `"eks.kaustubhk.com"` | no |
| <a name="input_argocd_hostname_prefix"></a> [argocd\_hostname\_prefix](#input\_argocd\_hostname\_prefix) | Prefix added to domain used for ArgoCD | `string` | `"argocd"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_central_eks_cluster"></a> [central\_eks\_cluster](#input\_central\_eks\_cluster) | Details of Central EKS cluster | <pre>object({<br>    cluster_name                      = string<br>    cluster_version                   = string<br>    publicly_accessible_cluster       = bool<br>    publicly_accessible_cluster_cidrs = list(string)<br>    cluster_support_type              = string<br>  })</pre> | <pre>{<br>  "cluster_name": "argocdstartercluster",<br>  "cluster_support_type": "STANDARD",<br>  "cluster_version": "1.30",<br>  "publicly_accessible_cluster": true,<br>  "publicly_accessible_cluster_cidrs": [<br>    "0.0.0.0/0"<br>  ]<br>}</pre> | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `"ipv4"` | no |
| <a name="input_eks_vpc_cni_custom_networking"></a> [eks\_vpc\_cni\_custom\_networking](#input\_eks\_vpc\_cni\_custom\_networking) | Use custom networking configuration for AWS VPC CNI | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"argocdstarter"` | no |
| <a name="input_sso_cluster_admin_role_name"></a> [sso\_cluster\_admin\_role\_name](#input\_sso\_cluster\_admin\_role\_name) | Name of AWS IAM Identity Center role added as cluster admin | `string` | `"AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags for all resources | `map(string)` | <pre>{<br>  "Environment": "Sample"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
