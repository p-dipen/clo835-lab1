# Specify AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  # require version
  required_version = "~> 1.2.1" # 1.1.5 or above and below 1.2.0
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ami-amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

}

# Get VPC id of default VPC
data "aws_vpc" "default" {
  default = true
}

# local variables
locals {
  default_tags = module.gloabl_vars.default_tags
  name_prefix  = "${module.gloabl_vars.prefix}-${module.gloabl_vars.env}"
}

# Retrieve default tags
module "gloabl_vars" {
  source = "./modules/global_vars"
}
# Provision SSH key pair for Linux VMs
resource "aws_key_pair" "linux_key" {
  key_name   = "linux_key"
  public_key = file(var.path_to_linux_key)
  tags = merge({
    Name = "${local.name_prefix}-keypair"
    },
    local.default_tags
  )
}



# Security Groups that allows SSH and HTTP access
module "vm_sg" {
  source     = "cloudposse/security-group/aws"
  version    = "0.4.3"
  attributes = ["primary"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow SSH from anywhere"
    },
    {
      key         = "HTTP"
      type        = "ingress"
      from_port   = 8080
      to_port     = 8081
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow HTTP from anywhere"
    }
  ]

  vpc_id = data.aws_vpc.default.id
  tags = merge({
    Name = "${local.name_prefix}-LinuxServer-sg"
    },
    local.default_tags
  )
}

# Create Amazon Linux EC2 instances in a default VPC
resource "aws_instance" "linux_vm" {
  count                  = var.num_linux_vms
  ami                    = data.aws_ami.ami-amzn2.id
  key_name               = aws_key_pair.linux_key.key_name
  instance_type          = var.vm_instance_type
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  user_data              = file("docker_install.sh")
  iam_instance_profile   = data.aws_iam_instance_profile.ec2_access_porfile.name
  vpc_security_group_ids = [module.vm_sg.id]
  tags = merge({
    Name = "${local.name_prefix}-LinuxServer-${count.index}"
    },
    local.default_tags
  )
}


resource "aws_ecr_repository" "cats" {
  name = "cats" # Naming my repository
}

resource "aws_ecr_repository" "dogs" {
  name = "dogs" # Naming my repository
}

# resource "aws_iam_role" "role" {
#   name               = "${local.name_prefix}-role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2008-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": ["ec2.amazonaws.com"]
#       },
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }


data "aws_iam_instance_profile" "ec2_access_porfile" {
  name = "LabInstanceProfile"
}

# resource "aws_iam_instance_profile" "profile" {
#   role = aws_iam_role.role.name
# }