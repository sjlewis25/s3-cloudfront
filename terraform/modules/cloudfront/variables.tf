variable "bucket_id" {
  description = "S3 bucket ID"
  type        = string
}

variable "bucket_regional_domain" {
  description = "S3 bucket regional domain name"
  type        = string
}

variable "origin_access_identity_path" {
  description = "CloudFront OAI path"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
