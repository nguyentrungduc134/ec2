terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.nano"
  key_name = "mykey-02"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
               sudo apt update -y
               sudo apt install python3-pip -y
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}


locals {
    inbound_ports = [22]
  }
resource "aws_security_group" "instance" {

  name = var.security_group_name

  dynamic "ingress" {
    for_each = local.inbound_ports
      content {
        from_port = ingress.value
        to_port = ingress.value
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
  }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "terraform-example-instance2"
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the Instance"
}
