data aws_region current {}
data aws_elb_service_account main {}

data aws_route53_zone main {
    name = var.domain_name
}

data aws_acm_certificate main {
    domain      = "*.${var.domain_name}"
    statuses    = ["ISSUED"]
    most_recent = true
}
