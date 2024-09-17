<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_lb_controller_service_account"></a> [aws\_lb\_controller\_service\_account](#module\_aws\_lb\_controller\_service\_account) | ../eksserviceaccount | n/a |
| <a name="module_external_dns_service_account"></a> [external\_dns\_service\_account](#module\_external\_dns\_service\_account) | ../eksserviceaccount | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID | `string` | n/a | yes |
| <a name="input_aws_partition"></a> [aws\_partition](#input\_aws\_partition) | AWS account partition | `string` | n/a | yes |
| <a name="input_deploy_external_dns"></a> [deploy\_external\_dns](#input\_deploy\_external\_dns) | True to deploy ExternalDNS controller | `bool` | n/a | yes |
| <a name="input_deploy_lb_controller"></a> [deploy\_lb\_controller](#input\_deploy\_lb\_controller) | True to deploy Load Balancer controller | `bool` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"argocdmanagedstarter"` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | ARN pf EKS Cluster OIDC provider | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
