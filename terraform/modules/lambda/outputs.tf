output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.validator.function_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.alerts.arn
}
