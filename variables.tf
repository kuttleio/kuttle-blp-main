variable env_tags {}
variable global_tags {}
variable account_id {}
variable ecr_region {}
variable clp_region {}
variable clp_account {}
variable domain_name {}
variable default_region {}
variable mezmo_account_id {}
variable provider_role_arn {}
variable default_state_bucket {}
variable aws_provider_session_name {}

variable whitelisted_ips {
  description = "Whitelisted IPs"
  type        = list(string)
  default     = [
    "0.0.0.0/0",
  ]
}
