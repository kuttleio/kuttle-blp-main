# ---------------------------------------------------
#   Security Group for Public LBs
# ---------------------------------------------------
resource "aws_security_group" "main" {
  name        = "${local.name_prefix}-${var.clp_zenv} LB SG"
  description = "LB Access SG"
  vpc_id      = var.vpc_id
  tags        = merge(var.standard_tags, tomap({ Name = "${local.name_prefix}-${var.clp_zenv} LB security group" }))

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------------
#   Public LB
# ---------------------------------------------------
resource "aws_lb" "loadbalancers" {
  for_each           = { for service_name, service_config in var.services : service_name => service_config if service_config.public == true }
  name               = "${local.name_prefix}-${var.clp_zenv}-${title(each.key)}-LB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.logs.bucket
    prefix  = "${lower(each.key)}_lb"
    enabled = true
  }

  tags = merge(var.standard_tags, tomap({ Name = "${local.name_prefix}-${var.clp_zenv}-${title(each.key)}-LB" }))
}

resource "aws_route53_record" "records" {
  for_each = { for service_name, service_config in var.services : service_name => service_config if service_config.public == true }
  zone_id  = data.aws_route53_zone.main.zone_id
  name     = try(coalesce(each.value.endpoint, ""), "") == "" ? "${var.clp_zenv}." : "${var.clp_zenv}-${each.value.endpoint}."
  type     = "CNAME"
  ttl      = 300
  records  = [aws_lb.loadbalancers[each.key].dns_name]
}


# ---------------------------------------------------
#   S3 bucket + policy
# ---------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket        = "${local.name_prefix}-${var.clp_zenv}-lb-logs"
  force_destroy = true
  tags          = var.standard_tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id = "logs"
    expiration {
      days = 30
    }
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = <<POLICY
{
    "Id": "LogBucketPolicy",
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": [
            "s3:PutObject"
            ],
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.logs.id}/*",
        "Principal": {
            "AWS": [
                    "${data.aws_elb_service_account.main.arn}"
                ]
            }
        }
    ]
}
POLICY
}

# ---------------------------------------------------
#   Public LBs - Outputs
# ---------------------------------------------------
output "public_lb_arn" {
  description = "Public LB ARN"
  value       = { for k, v in aws_lb.loadbalancers : k => v.arn }
}

output "url" {
  value = { for k, v in aws_route53_record.records : k => "https://${v.fqdn}" }
}

output "fqdn" {
  value = { for k, v in aws_route53_record.records : k => v.fqdn }
}
