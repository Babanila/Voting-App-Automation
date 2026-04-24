provider "aws" {
  region = var.aws_region
}


# Create Buckets using the custom bucket module
module "backups_bucket" {
  source = "./modules/custom-bucket"
  name   = "backups-bucket-${var.author_name}"
  tags = {
    Purpose = "backups"
    Owner   = var.author_name
  }
}


# Create VPC and pass in exactly the variables your module expects
module "custom_vpc" {
  source = "./modules/vpc"

  aws_region     = var.aws_region
  cidr_block     = var.cidr_block
  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
  instance_type  = var.instance_type
  ami_id = var.ami_id
  key_pair_name  = var.key_pair_name
  author_name    = var.author_name
  my_ip_cidr     = var.my_ip_cidr
}


# FRONTEND (Public)
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.custom_vpc.public_subnet_id
  vpc_security_group_ids      = [module.custom_vpc.frontend_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_instances["frontend"]
  }

  depends_on = [module.custom_vpc]
}


# BACKEND (Private)
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.custom_vpc.private_subnet_id
  vpc_security_group_ids = [module.custom_vpc.backend_sg_id]
  key_name               = var.key_pair_name

  tags = {
    Name = var.ec2_instances["backend"]
  }

  depends_on = [module.custom_vpc]
}


# DATABASE (Private)
resource "aws_instance" "database" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.custom_vpc.private_subnet_id
  vpc_security_group_ids = [module.custom_vpc.database_sg_id]
  key_name               = var.key_pair_name

  tags = {
    Name = var.ec2_instances["database"]
  }

  depends_on = [module.custom_vpc]
}
