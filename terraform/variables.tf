variable "region" {
  description = "AWS Region to deploy resources"
  default     = "us-east-1"
}

variable "lambda_code_s3_bucket" {
  description = "S3 bucket where Lambda code is stored"
}

variable "lambda_code_s3_key" {
  description = "S3 key for the Lambda zip file"
}
