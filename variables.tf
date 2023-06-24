variable vpc_id {}
variable secrets {}
variable envvars {}
variable clp_zenv {}
variable clp_region {}
variable clp_account {}
variable account_id {}
variable ecr_region {}
variable domain_name {}
variable github_token {}
variable github_owner {}
variable ecr_account_id {}
variable standard_tags {}
variable public_subnets {}
variable private_subnets {}
variable security_groups {}
variable s3_tf_artefacts {}
variable mezmo_account_id {}
variable provider_role_arn {}
variable logdna_service_key {}
variable aws_provider_session_name {}

variable whitelisted_ips {
  description = "Whitelisted IPs"
  type        = list(string)
  default     = [
    "0.0.0.0/0",
  ]
}
