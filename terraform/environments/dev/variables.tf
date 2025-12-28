variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "S3 bucket name (must be globally unique)"
  type        = string
}

variable "alert_email" {
  description = "Email for CloudWatch alerts"
  type        = string
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default = {
    Project     = "S3-Portfolio"
    ManagedBy   = "Terraform"
  }
}
