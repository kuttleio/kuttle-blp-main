variable vpc_id {}
variable subnets {}
variable clp_region {}
variable clp_account {}
variable clp_zenv {}
variable account_id {}
variable domain_name {}
variable ecr_region {}
variable ecr_account_id {}
variable standard_tags {}
variable security_groups {}
variable mezmo_account_id {}

variable logdna_service_key {}
variable github_token {}
variable guthub_owner {}

variable whitelisted_ips {
  description = "Whitelisted IPs"
  type        = list(string)
  default     = [
    "0.0.0.0/0",
  ]
}
