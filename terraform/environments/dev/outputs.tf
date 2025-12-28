output "website_url" {
  description = "CloudFront distribution URL"
  value       = module.cloudfront.distribution_domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3_website.bucket_id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}
