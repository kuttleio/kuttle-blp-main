# ------------------------------------
#       ECS Task Role
# ------------------------------------
resource aws_iam_role main {
  name = "${local.name_prefix}-${var.clp_zenv}"
  tags = local.standard_tags

  managed_policy_arns = [
    aws_iam_policy.sqs.arn,
    aws_iam_policy.s3.arn,
    aws_iam_policy.ecs.arn,
    aws_iam_policy.rds.arn,
    aws_iam_policy.pricing.arn,  
  ]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource aws_iam_policy sqs {
  name = "${local.name_prefix}-${var.clp_zenv}-sqs"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "stmt1617103351726",
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": [
        "${aws_sqs_queue.main.arn}",
        "${aws_sqs_queue.reversed.arn}"
      ]
    }
  ]
}
POLICY
}

resource aws_iam_policy s3 {
  name = "${local.name_prefix}-${var.clp_zenv}-s3"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "stmt1617103351726",
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${var.s3_tf_artefacts}",
        "${var.s3_tf_artefacts}/*"
      ]
    }
  ]
}
POLICY
}

resource aws_iam_policy ecs {
  name = "${local.name_prefix}-${var.clp_zenv}-ecs"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "stmt1617103351726",
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
          "ecs:cluster": "${module.ecs_fargate.cluster_arn}"
        }
      }
    }
  ]
}
POLICY
}

resource aws_iam_policy rds {
  name        = "${local.name_prefix}-${var.clp_zenv}-rds"
  description = "RDS Policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1617103351727",
      "Effect": "Allow",
      "Action": "rds:DescribeDBInstances",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource aws_iam_policy pricing {
  name        = "${local.name_prefix}-${var.clp_zenv}-pricing"
  description = "IAM Role Policy"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1617103351727",
      "Effect": "Allow",
      "Action": [
        "pricing:DescribeServices",
        "pricing:GetProducts"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}
