terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0.0"
        }
    }
    required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create key pair using local public key
resource "aws_key_pair" "deployer" {
    key_name = var.key_name
    public_key = file(var.public_key_path)
}

# Security group
resource "aws_security_group" "instance_sg" {
    name = "flask-express-sg"
    description = "Allow SSH + app ports"
    vpc_id = data.aws_vpc.default.id

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Express (8000)"
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Flask (5000)"
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = var.tags
}

# Use default VPC (most accounts have one)
data "aws_vpc" "default" {
    default = true
}


data "aws_subnets" "default" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}


# Find latest Amazon Linux 2 AMI
data "aws_ami" "amazonlinux2" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    }
}


# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Resources Block
resource "aws_instance" "app_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.deployer.key_name
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    subnet_id = element(data.aws_subnets.default.ids, 0)
    associate_public_ip_address = true
    user_data = file("${path.module}/user_data.sh")
    tags = merge(var.tags, { "Name" = "flask-express-instance" })
}