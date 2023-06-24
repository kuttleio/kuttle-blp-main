# ---------------------------------------------------
#    LogDNA
# ---------------------------------------------------
resource logdna_view main {
    name        = "${var.clp_zenv}-${local.short_region_name} - logs"
    query       = "-health"
    categories  = ["DEV"]
    tags        = ["${local.name_prefix}-${var.clp_zenv}"]
}

resource logdna_view errors {
    levels      = ["error"]
    name        = "${var.clp_zenv}-${local.short_region_name} - errors"
    query       = "-health"
    categories  = ["DEV"]
    tags        = ["${local.name_prefix}-${var.clp_zenv}"]

    # slack_channel {
    #     immediate       = "true"
    #     operator        = "presence"
    #     terminal        = "false"
    #     triggerinterval = "30"
    #     triggerlimit    = 1
    #     url             = var.logdna_slack_non_prod_alerts
    # }
}

# ---------------------------------------------------
#    LogDNA pushing logs from CloudWatch
# ---------------------------------------------------
module lambda {
    source  = "terraform-aws-modules/lambda/aws"
    version = "~> 4.0"

    function_name                       = "${local.name_prefix}-${var.clp_zenv}-logdna-lambda"
    description                         = "Push CloudWatch logs to LogDNA for ${var.clp_zenv}-${local.short_region_name}"
    handler                             = "index.handler"
    runtime                             = "nodejs18.x"
    timeout                             = 10
    memory_size                         = 256
    maximum_retry_attempts              = 0
    create_package                      = false
    local_existing_package              = "${path.module}/lambda.zip"
    tags                                = local.standard_tags
    cloudwatch_logs_retention_in_days   = 1

    environment_variables = {
        LOGDNA_KEY          = var.logdna_service_key
        LOGDNA_TAGS         = "${local.name_prefix}-${var.clp_zenv}"
        LOG_RAW_EVENT       = "yes"
    }
}

resource aws_lambda_permission allow_cloudwatch {
    action        = "lambda:InvokeFunction"
    function_name = module.lambda.lambda_function_name
    principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
}

# ---------------------------------------------------
#   Mezmo (LogDNA) - Outputs
# ---------------------------------------------------
output logdna_view_url {
    value = "https://app.mezmo.com/${var.mezmo_account_id}/logs/view/${logdna_view.main.id}"
}

output logdna_view_id {
    value = logdna_view.main.id
}
