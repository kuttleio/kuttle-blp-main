locals {
    region_name_bits    = split("-", var.clp_region)
    short_region_name   = "${local.region_name_bits[0]}${substr(local.region_name_bits[1], 0, 1)}${substr(local.region_name_bits[2], 0, 1)}"
    name_prefix         = "${local.short_region_name}-${var.clp_account}"
}

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
    tags                                = var.standard_tags
    cloudwatch_logs_retention_in_days   = 1

    environment_variables = {
        LOGDNA_KEY          = data.aws_ssm_parameter.logdna_service_key.value
        LOGDNA_TAGS         = "${local.name_prefix}-${var.clp_zenv}"
        LOG_RAW_EVENT       = "yes"
    }
}

resource aws_lambda_permission allow_cloudwatch {
    action        = "lambda:InvokeFunction"
    function_name = module.lambda.lambda_function_name
    principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
}


