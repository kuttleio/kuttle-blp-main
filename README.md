<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.0 |
| <a name="requirement_logdna"></a> [logdna](#requirement\_logdna) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.0 |
| <a name="provider_logdna"></a> [logdna](#provider\_logdna) | ~> 1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_fargate"></a> [ecs\_fargate](#module\_ecs\_fargate) | terraform-aws-modules/ecs/aws | 4.1.3 |
| <a name="module_force_new_deployment"></a> [force\_new\_deployment](#module\_force\_new\_deployment) | github.com/kuttleio/aws_ecs_fargate_force_new_deployment// | 2.0.0 |
| <a name="module_logdna"></a> [logdna](#module\_logdna) | terraform-aws-modules/lambda/aws | ~> 4.0 |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | terraform-aws-modules/rds/aws | ~> 5.0 |
| <a name="module_services"></a> [services](#module\_services) | github.com/kuttleio/aws_ecs_fargate_app | 1.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_policy.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.pricing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb.loadbalancers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_route53_record.records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.reversed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_ssm_parameter.postgres_connection_string](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_wafv2_ip_set.whitelisted_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.waf_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.acl_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [github_repository_file.respository_files](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [logdna_view.main](https://registry.terraform.io/providers/logdna/logdna/latest/docs/resources/view) | resource |
| [random_password.postgres](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.logdna_service_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [github_repository.repositories](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_clp_account"></a> [clp\_account](#input\_clp\_account) | n/a | `any` | n/a | yes |
| <a name="input_clp_region"></a> [clp\_region](#input\_clp\_region) | n/a | `any` | n/a | yes |
| <a name="input_clp_zenv"></a> [clp\_zenv](#input\_clp\_zenv) | n/a | `any` | n/a | yes |
| <a name="input_database_allocated_storage"></a> [database\_allocated\_storage](#input\_database\_allocated\_storage) | n/a | `string` | `"20"` | no |
| <a name="input_database_max_allocated_storage"></a> [database\_max\_allocated\_storage](#input\_database\_max\_allocated\_storage) | n/a | `string` | `"100"` | no |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | n/a | `string` | `"5432"` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | n/a | `string` | `"kuttle"` | no |
| <a name="input_datastores"></a> [datastores](#input\_datastores) | n/a | <pre>map(object({<br>    name                           = string<br>    type                           = string<br>    engine                         = string<br>    version                        = string<br>    class                          = string<br>    instance                       = string<br>    autoscaling                    = string<br>    allocated_storage              = optional(number)<br>    database_max_allocated_storage = optional(number)<br>    database_username              = optional(string)<br>    database_port                  = optional(number)<br>    tags                           = optional(map(string))<br>  }))</pre> | <pre>{<br>  "postgres1": {<br>    "autoscaling": "enabled",<br>    "class": "burstable",<br>    "engine": "postgres",<br>    "instance": "t4g.micro",<br>    "name": "postgre",<br>    "type": "SQL",<br>    "version": "15.2"<br>  }<br>}</pre> | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `any` | n/a | yes |
| <a name="input_ecr_account_id"></a> [ecr\_account\_id](#input\_ecr\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_ecr_region"></a> [ecr\_region](#input\_ecr\_region) | n/a | `any` | n/a | yes |
| <a name="input_envvars"></a> [envvars](#input\_envvars) | n/a | `any` | n/a | yes |
| <a name="input_mezmo_account_id"></a> [mezmo\_account\_id](#input\_mezmo\_account\_id) | n/a | `any` | n/a | yes |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `any` | n/a | yes |
| <a name="input_s3_tf_artefacts"></a> [s3\_tf\_artefacts](#input\_s3\_tf\_artefacts) | n/a | `any` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | n/a | `any` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | `any` | n/a | yes |
| <a name="input_services"></a> [services](#input\_services) | Map of service names and configurations | <pre>map(object({<br>    public               = bool<br>    type                 = string<br>    name                 = string<br>    cpu                  = number<br>    memory               = number<br>    service_discovery_id = string<br>    environment          = list(object({ name = string, value = string }))<br>    secrets              = optional(list(object({ name = string, valueFrom = string })))<br>    tags                 = optional(map(string))<br>  }))</pre> | <pre>{<br>  "backend": {<br>    "cpu": 256,<br>    "environment": [<br>      {<br>        "name": "UPDATE_STATUSES_CRON",<br>        "value": "*/10 * * * *"<br>      },<br>      {<br>        "name": "IS_WORKER",<br>        "value": "1"<br>      }<br>    ],<br>    "memory": 512,<br>    "name": "backend",<br>    "public": true,<br>    "service_discovery_id": "",<br>    "type": "non-frontend"<br>  },<br>  "frontend": {<br>    "cpu": 256,<br>    "environment": [],<br>    "memory": 512,<br>    "name": "frontend",<br>    "public": true,<br>    "service_discovery_id": "",<br>    "type": "frontend"<br>  },<br>  "runner": {<br>    "cpu": 256,<br>    "environment": [],<br>    "memory": 512,<br>    "name": "runner",<br>    "public": false,<br>    "service_discovery_id": "",<br>    "type": "non-frontend"<br>  }<br>}</pre> | no |
| <a name="input_standard_tags"></a> [standard\_tags](#input\_standard\_tags) | n/a | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `any` | n/a | yes |
| <a name="input_whitelisted_ips"></a> [whitelisted\_ips](#input\_whitelisted\_ips) | n/a | <pre>map(object({<br>    addresses = list(string)<br>  }))</pre> | <pre>{<br>  "default": {<br>    "addresses": [<br>      "0.0.0.0/1",<br>      "128.0.0.0/1"<br>    ]<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ECS Fargate Cluster ARN |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ECS Fargate Cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | ECS Fargate Cluster Name |
| <a name="output_ecr_repo_url"></a> [ecr\_repo\_url](#output\_ecr\_repo\_url) | n/a |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | n/a |
| <a name="output_logdna_view_id"></a> [logdna\_view\_id](#output\_logdna\_view\_id) | n/a |
| <a name="output_logdna_view_url"></a> [logdna\_view\_url](#output\_logdna\_view\_url) | --------------------------------------------------- Mezmo (LogDNA) - Outputs --------------------------------------------------- |
| <a name="output_public_lb_arn"></a> [public\_lb\_arn](#output\_public\_lb\_arn) | Public LB ARN |
| <a name="output_url"></a> [url](#output\_url) | n/a |
<!-- END_TF_DOCS -->