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
| <a name="module_fcknat"></a> [fcknat](#module\_fcknat) | git::https://github.com/RaJiska/terraform-aws-fck-nat.git | 9377bf9247c96318b99273eb2978d1afce8cf0eb |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git | e226cc15a7b8f62fd0e108792fea66fa85bcb4b9 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"argocdstarter"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags for all resources | `map(string)` | <pre>{<br>  "Environment": "Sample"<br>}</pre> | no |
| <a name="input_use_ha_nat"></a> [use\_ha\_nat](#input\_use\_ha\_nat) | Use NAT in HA mode | `bool` | `false` | no |
| <a name="input_use_managed_nat"></a> [use\_managed\_nat](#input\_use\_managed\_nat) | Use AWS managed NAT. If false, fck-nat is used instead | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_private_cidrs"></a> [vpc\_private\_cidrs](#input\_vpc\_private\_cidrs) | CIDRs for VPC private subnets | `list(string)` | <pre>[<br>  "10.0.0.0/20",<br>  "10.0.16.0/20",<br>  "10.0.32.0/20",<br>  "10.0.48.0/20",<br>  "10.0.64.0/20",<br>  "10.0.80.0/20"<br>]</pre> | no |
| <a name="input_vpc_public_cidrs"></a> [vpc\_public\_cidrs](#input\_vpc\_public\_cidrs) | CIDRs for VPC public subnets | `list(string)` | <pre>[<br>  "10.0.96.0/20",<br>  "10.0.112.0/20",<br>  "10.0.128.0/20",<br>  "10.0.144.0/20",<br>  "10.0.160.0/20",<br>  "10.0.176.0/20"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
