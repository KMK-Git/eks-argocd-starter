<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.67.0 |
| <a name="provider_helm.argocdcluster"></a> [helm.argocdcluster](#provider\_helm.argocdcluster) | 2.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | git::https://github.com/aws-ia/terraform-aws-eks-blueprints-addons.git | a9963f4a0e168f73adb033be594ac35868696a91 |
| <a name="module_managed_eks"></a> [managed\_eks](#module\_managed\_eks) | git::https://github.com/terraform-aws-modules/terraform-aws-eks.git | c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.argocd_admin_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.argocd_admin_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.argocd_admin_assume_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [helm_release.argocdmanagedcluster](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.argocd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_role.argocd_service_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.route53_zones](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_security_group.central_cluster_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_central_cluster_name"></a> [central\_cluster\_name](#input\_central\_cluster\_name) | Name used for central cluster | `string` | `"argocdstartercluster"` | no |
| <a name="input_central_name_prefix"></a> [central\_name\_prefix](#input\_central\_name\_prefix) | Prefix used for central cluster resource names | `string` | `"argocdstarter"` | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `"ipv4"` | no |
| <a name="input_eks_vpc_cni_custom_networking"></a> [eks\_vpc\_cni\_custom\_networking](#input\_eks\_vpc\_cni\_custom\_networking) | Use custom networking configuration for AWS VPC CNI | `bool` | `true` | no |
| <a name="input_enable_aws_load_balancer_controller"></a> [enable\_aws\_load\_balancer\_controller](#input\_enable\_aws\_load\_balancer\_controller) | Enable AWS Load Balancer Controller add-on | `bool` | `false` | no |
| <a name="input_enable_external_dns"></a> [enable\_external\_dns](#input\_enable\_external\_dns) | Enable external-dns operator add-on | `bool` | `false` | no |
| <a name="input_enable_metrics_server"></a> [enable\_metrics\_server](#input\_enable\_metrics\_server) | Enable metrics server add-on | `bool` | `true` | no |
| <a name="input_managed_eks_cluster"></a> [managed\_eks\_cluster](#input\_managed\_eks\_cluster) | Details of Managed EKS cluster | <pre>object({<br>    cluster_name                      = string<br>    cluster_version                   = string<br>    publicly_accessible_cluster       = bool<br>    publicly_accessible_cluster_cidrs = list(string)<br>    cluster_support_type              = string<br>  })</pre> | <pre>{<br>  "cluster_name": "argocdmanagedcluster",<br>  "cluster_support_type": "STANDARD",<br>  "cluster_version": "1.30",<br>  "publicly_accessible_cluster": true,<br>  "publicly_accessible_cluster_cidrs": [<br>    "0.0.0.0/0"<br>  ]<br>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"argocdmanagedstarter"` | no |
| <a name="input_route53_zone_names"></a> [route53\_zone\_names](#input\_route53\_zone\_names) | List of names of route 53 zones which are managed by ExternalDNS, if enabled | `list(string)` | `[]` | no |
| <a name="input_sso_cluster_admin_role_name"></a> [sso\_cluster\_admin\_role\_name](#input\_sso\_cluster\_admin\_role\_name) | Name of AWS IAM Identity Center role added as cluster admin | `string` | `"AWSReservedSSO_AWSAdministratorAccess_1bbf9fcc3b81288e"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags for all resources | `map(string)` | <pre>{<br>  "Environment": "Sample"<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
