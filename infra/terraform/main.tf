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

  aws_region         = var.aws_region
  cidr_block         = var.cidr_block
  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
  instance_type      = var.instance_type
  ami_id             = var.ami_id
  key_pair_name      = var.key_pair_name
  author_name        = var.author_name
  my_ip_cidr         = var.my_ip_cidr
}


# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "docker_logs" {
  name              = "/aws/ec2/docker/all"
  retention_in_days = 7

  tags = {
    Name = "docker-logs-${var.author_name}"
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/ec2/system/all"
  retention_in_days = 7

  tags = {
    Name = "system-logs-${var.author_name}"
  }
}

# CloudWatch IAM Role
resource "aws_iam_role" "cloudwatch_role" {
  name = "ec2-cloudwatch-role-${var.author_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach CloudWatch policy to role
resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "cloudwatch_profile" {
  name = "ec2-cloudwatch-profile-${var.author_name}"
  role = aws_iam_role.cloudwatch_role.name
}


# FRONTEND (Public)
resource "aws_instance" "frontend" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.custom_vpc.public_subnet_id
  vpc_security_group_ids      = [module.custom_vpc.frontend_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_profile.name

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
  iam_instance_profile   = aws_iam_instance_profile.cloudwatch_profile.name

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
  iam_instance_profile   = aws_iam_instance_profile.cloudwatch_profile.name

  tags = {
    Name = var.ec2_instances["database"]
  }

  depends_on = [module.custom_vpc]
}

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = module.custom_vpc.public_subnet_id
  vpc_security_group_ids      = [module.custom_vpc.bastion_sg_id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_instances["bastion"]
  }

  depends_on = [module.custom_vpc]
}
