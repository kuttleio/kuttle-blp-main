# ---------------------------------------------------
#   Mezmo (LogDNA) - Outputs
# ---------------------------------------------------
output logdna_view_url {
    value = "https://app.mezmo.com/${var.mezmo_account_id}/logs/view/${logdna_view.main.id}"
}

output logdna_view_id {
    value = logdna_view.main.id
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = module.lambda.lambda_function_arn
}
