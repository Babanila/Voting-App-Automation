output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}
