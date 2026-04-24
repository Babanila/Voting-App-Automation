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
  type        = string
  description = "Used for naming resources"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", lower(var.author_name)))
    error_message = "author_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "my_ip_cidr" {
  type        = string
  description = "Your IP for SSH access"
}

variable "ec2_instances" {
  description = "A map of instance identifiers to Name tags"
  type        = map(string)
}
