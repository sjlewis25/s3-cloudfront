output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "bucket_regional_domain_name" {
  description = "S3 bucket regional domain name"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "origin_access_identity_path" {
  description = "CloudFront origin access identity path"
  value       = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
}
