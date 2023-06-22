variable vpc_id {}
variable subnets {}
variable clp_region {}
variable clp_account {}
variable clp_zenv {}
variable account_id {}
variable name_prefix {}
variable domain_name {}
variable ecr_region {}
variable ecr_account_id {}
variable security_groups {}
variable mezmo_account_id {}

variable whitelisted_ips {
  description = "Whitelisted IPs"
  type        = list(string)
  default     = [
    "0.0.0.0/0",
  ]
}
