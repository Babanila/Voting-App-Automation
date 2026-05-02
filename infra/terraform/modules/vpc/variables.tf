variable "ami_id" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "private_cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the AWS key pair to use for SSH access"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "author_name" {
    type = string
    description = "The name of the author to include in the EC2 instance tags."
}

variable "my_ip_cidr" {
  type        = string
  description = "The CIDR block for your public IP address."
}
