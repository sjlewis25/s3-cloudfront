terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 bucket for website hosting
module "s3_website" {
  source = "../../modules/s3"
  
  bucket_name = var.bucket_name
  environment = var.environment
  tags        = var.tags
}

# CloudFront distribution
module "cloudfront" {
  source = "../../modules/cloudfront"
  
  bucket_id                = module.s3_website.bucket_id
  bucket_regional_domain   = module.s3_website.bucket_regional_domain_name
  origin_access_identity_path = module.s3_website.origin_access_identity_path
  environment              = var.environment
  tags                     = var.tags
}

# Lambda for file validation
module "lambda_validation" {
  source = "../../modules/lambda"
  
  bucket_id   = module.s3_website.bucket_id
  bucket_arn  = module.s3_website.bucket_arn
  environment = var.environment
  tags        = var.tags
}

# Monitoring and alarms
module "monitoring" {
  source = "../../modules/monitoring"
  
  bucket_name           = var.bucket_name
  cloudfront_distribution_id = module.cloudfront.distribution_id
  sns_email             = var.alert_email
  environment           = var.environment
  tags                  = var.tags
}
