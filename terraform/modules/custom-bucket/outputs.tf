output "bucket_id" {
  description = "The ID of the S3 bucket created for Terraform state"
  value       = aws_s3_bucket.tfstate.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket created for Terraform state"
  value = aws_s3_bucket.tfstate.arn
}

output "lock_table_name" {
  description = "The name of the DynamoDB table created for state locking"
  value       = aws_dynamodb_table.tflock.name
}
