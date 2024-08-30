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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/terraform-aws-modules/terraform-aws-eks.git | c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | git::https://github.com/terraform-aws-modules/terraform-aws-eks.git//modules/karpenter | c60b70fbc80606eb4ed8cf47063ac6ed0d8dd435 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git | e226cc15a7b8f62fd0e108792fea66fa85bcb4b9 |

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b"<br>]</pre> | no |
| <a name="input_cluster_ip_family"></a> [cluster\_ip\_family](#input\_cluster\_ip\_family) | The IP family used to assign Kubernetes pod and service addresses. Valid values are `ipv4` (default) and `ipv6`. You can only specify an IP family when you create a cluster, changing this value will force a new cluster to be created | `string` | `"ipv4"` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes <major>.<minor> version to use for the EKS cluster | `string` | `"1.30"` | no |
| <a name="input_eks_vpc_cni_custom_networking"></a> [eks\_vpc\_cni\_custom\_networking](#input\_eks\_vpc\_cni\_custom\_networking) | Use custom networking configuration for AWS VPC CNI | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for resource names | `string` | `"starter"` | no |
| <a name="input_publicly_accessible_cluster"></a> [publicly\_accessible\_cluster](#input\_publicly\_accessible\_cluster) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_publicly_accessible_cluster_cidrs"></a> [publicly\_accessible\_cluster\_cidrs](#input\_publicly\_accessible\_cluster\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags for all resources | `map(string)` | <pre>{<br>  "Environment": "Sample"<br>}</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR for VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_private_cidrs"></a> [vpc\_private\_cidrs](#input\_vpc\_private\_cidrs) | CIDRs for VPC private subnets | `list(string)` | `[]` | no |
| <a name="input_vpc_public_cidrs"></a> [vpc\_public\_cidrs](#input\_vpc\_public\_cidrs) | CIDRs for VPC public subnets | `list(string)` | <pre>[<br>  "10.0.0.0/20",<br>  "10.0.16.0/20",<br>  "10.0.32.0/20",<br>  "10.0.48.0/20"<br>]</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
