terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-west-1"
  profile = "souji2profilename"
}

variable "vpc_id" {
  default = "vpc-044e04c43b04768b2"
}

variable "key_name" {
  default = "homework5"
}

resource "aws_security_group" "jeffm_ucsc_ssh" {
  name   = "jeffm_test_ec2_ssh"
  vpc_id = var.vpc_id

  tags = {
    Name = "SEQAX409-AdvDevOps"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["X.X.X.X/32"]  # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jeffm_ucsc_app" {
  name   = "jeffm_test_ec2_flask_app"
  vpc_id = var.vpc_id

  tags = {
    Name = "SEQAX409-AdvDevOps"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["my_first_ami_*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["904233115421"]
}

resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jeffm_ucsc_ssh.id, aws_security_group.jeffm_ucsc_app.id]
  key_name               = var.key_name

  count = 2

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

output "hostid" {
  value = [for instance in aws_instance.app_server : instance.public_dns]
}
