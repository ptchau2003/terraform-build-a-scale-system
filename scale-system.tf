### Create an autoscaling system in Default VPC with:
### 1. ALB
### 2. ASG
### 3. Target Group
### 4. Launching Config
### 5. EC2

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

# Global variables
variable "region" {
  default = "us-east-1"
}
variable "certificate_arn" {
  type = string
  description = "The local certificate ARN was get from previous step"
}
variable "publickey_directory" {
  description = "The directory of RSA private key created: /home/<user>/.ssh/id_rsa.pub"
  default     = "id_rsa.pub"
}
variable "env" {
  description = "Enviroment: Dev/Test/UAT"
  default =   "Dev"
}

variable "project-name" {
  type = string
  description = "Your project name"
  default = "TestBed"
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
# Launch configuration data
resource "aws_key_pair" "ec2-key" {
  key_name   = "ec2-key"
  public_key = file(var.publickey_directory)
}

variable "launch-configuration-ami" {
  default = "ami-00514a528eadbc95b"
}

variable "launch-configuration-instance-type" {
  default = "t3.micro"
}

# Launch configuration for EC2

resource "aws_security_group" "ec2-sg" {
  name = "ec2-sg"
  description = "Security Group allowing Incoming traffic for EC2 from ALB"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.loadbalance-sg.id]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment  = var.env
  }
}

resource "aws_launch_template" "launch-configuration-template" {
  name             = var.project-name
  image_id         = var.launch-configuration-ami
  instance_type    = var.launch-configuration-instance-type
  key_name         = aws_key_pair.ec2-key.id
  vpc_security_group_ids  = [aws_security_group.ec2-sg.id]
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20
      volume_type    = "standard"
    }
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      enviroment = var.env
    }
  }
  user_data = filebase64("/home/cloud_user/terraform-build-a-scale-system/install_nginx.sh")
}
# Autoscaling group

data "aws_availability_zones" "all_available" {
 all_availability_zones = true
 filter {
   name   = "opt-in-status"
   values = ["opt-in-not-required"]
   }
}
resource "aws_autoscaling_group" "auto-scaling-group" {
  name                 = var.project-name
  availability_zones = data.aws_availability_zones.all_available.names
  desired_capacity   = 1
  min_size           = 1
  max_size           = 4
  target_group_arns  = [aws_lb_target_group.auto-target-group.arn]
  launch_template {
    id      = aws_launch_template.launch-configuration-template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "auto-scaling-policy-CPU" {
  name                   = "CPU"
  autoscaling_group_name = aws_autoscaling_group.auto-scaling-group.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0 #CPU60%
  }
}
resource "aws_autoscaling_policy" "auto-scaling-policy-BW" {
  name                   = "BW"
  autoscaling_group_name = aws_autoscaling_group.auto-scaling-group.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageNetworkIn"
    }
    target_value = 600000000.0  #600Mbytes
  }
}
# Target Group
resource "aws_lb_target_group" "auto-target-group" {
  name     = var.project-name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

#  ALB creation - This is Front End Application

resource "aws_security_group" "loadbalance-sg" {
  name = "loadbalance-sg"
  description = "Security Group allowing Incoming traffic to ALB"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    environment  = var.env
  }
} 
data "aws_subnet_ids" "default" {
  vpc_id = aws_default_vpc.default.id
}
resource "aws_lb" "application-load-balancer" {
  name               = var.project-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalance-sg.id]
  subnets	     = data.aws_subnet_ids.default.ids
  enable_deletion_protection = false
  tags = {
    environment = var.env
  }
  provisioner "local-exec" {
    command = "echo ${aws_lb.application-load-balancer.dns_name}"
  }
}

resource "aws_lb_listener" "application-listener-https" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auto-target-group.arn
  }
}

resource "aws_lb_listener" "application-listener-http" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
