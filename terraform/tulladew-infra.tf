# Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "ami" {
  description = "AMI ID"
  default     = "ami-0889a44b331db0194"
}

variable "key_name" {
  description = "Key Pair Name"
  default     = "tulladewKeyTerraform"
}

# Provider
provider "aws" {
  region = var.region
}

# Key Pair
resource "aws_key_pair" "tulladew_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/${var.key_name}.pem.pub")
}

# Security Group
resource "aws_security_group" "tulladew_sg" {
  name        = "tulladewSG_Terraform"
  description = "Security group for Tulladew EC2 instance via Terraform"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "tulladew_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.tulladew_key.key_name

  vpc_security_group_ids = [aws_security_group.tulladew_sg.id]

  user_data = file("user-data.sh")

  tags = {
    Name    = "Terraform Tulladew"
    EnvName = "Test Environment"
  }
}