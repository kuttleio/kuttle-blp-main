resource aws_sqs_queue main {
  name                        = "${local.name_prefix}-${var.clp_zenv}"
  visibility_timeout_seconds  = 900
  tags                        = var.standard_tags
  sqs_managed_sse_enabled     = true
}

resource aws_sqs_queue reversed {
  name                        = "${local.name_prefix}-${var.clp_zenv}-reversed"
  visibility_timeout_seconds  = 900
  tags                        = var.standard_tags
  sqs_managed_sse_enabled     = true
}
