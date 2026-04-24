output "public_ip" {
  value = { for k, v in aws_instance.servers : k => v.public_ip }
}

output "public_dns" {
  value = { for k, v in aws_instance.servers : k => v.public_dns }
}

output "backup_bucket_arn" {
  value = module.backups_bucket.bucket_arn
}

output "backend_bucket" {
  value = module.terraform_backend.bucket_id
}

output "backend_lock_table" {
  value = module.terraform_backend.lock_table_name
}

output "frontend_public_ip" {
  value = aws_security_group.frontend_sg.public_ip
}

output "backend_private_ip" {
  value = aws_security_group.backend_sg.private_ip
}

output "database_private_ip" {
  value = aws_security_group.database_sg.private_ip
}
