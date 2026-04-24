output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "frontend_public_dns" {
  value = aws_instance.frontend.public_dns
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "database_private_ip" {
  value = aws_instance.database.private_ip
}

output "backup_bucket_arn" {
  value = module.backups_bucket.bucket_arn
}

output "backend_bucket" {
  value = module.backups_bucket.bucket_id
}

output "backend_lock_table" {
  value = module.backups_bucket.lock_table_name
}

output "frontend_sg_public_ip" {
  value = module.custom_vpc.frontend_sg_id
}

output "backend_sg_private_ip" {
  value = module.custom_vpc.backend_sg_id
}

output "database_sg_private_ip" {
  value = module.custom_vpc.database_sg_id
}
