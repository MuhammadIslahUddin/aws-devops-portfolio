variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_base_name" {
  description = "Base name for S3 bucket"
  type        = string
  default     = "devops-portfolio-frontend"
}

