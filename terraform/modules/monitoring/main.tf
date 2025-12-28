# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "s3-portfolio-alerts-${var.environment}"
  tags = var.tags
}

# SNS email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# CloudWatch alarm for 4xx errors
resource "aws_cloudwatch_metric_alarm" "cloudfront_4xx" {
  alarm_name          = "cloudfront-4xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "Alerts when 4xx error rate exceeds 5%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DistributionId = var.cloudfront_distribution_id
  }

  tags = var.tags
}

# CloudWatch alarm for 5xx errors
resource "aws_cloudwatch_metric_alarm" "cloudfront_5xx" {
  alarm_name          = "cloudfront-5xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alerts when 5xx error rate exceeds 1%"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DistributionId = var.cloudfront_distribution_id
  }

  tags = var.tags
}

# CloudWatch alarm for S3 bucket size
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  alarm_name          = "s3-bucket-size-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400"
  statistic           = "Average"
  threshold           = "1073741824"
  alarm_description   = "Alerts when S3 bucket exceeds 1GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    BucketName  = var.bucket_name
    StorageType = "StandardStorage"
  }

  tags = var.tags
}
