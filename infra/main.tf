terraform {
  cloud {
    organization = "dev-knot"
    workspaces {
      name = "aws-app-runner-ansible-eda"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}

resource "aws_ecr_repository" "ansible_eda" {
  name                 = "ansible-eda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_apprunner_service" "aws-app-runner-ansible-eda" {
  service_name = "aws-app-runner-ansible-eda"

  source_configuration {
    image_repository {
      image_configuration {
        port = "5000"
      }
      image_identifier      = "${aws_ecr_repository.ansible_eda.repository_url}/${aws_ecr_repository.ansible_eda.name}:latest"
      image_repository_type = "ECR"
    }
    auto_deployments_enabled = false
  }
  health_check_configuration {
          healthy_threshold   = 1
          interval            = 10
          path                = "/"
          protocol            = "TCP"
          timeout             = 5
          unhealthy_threshold = 5
        }
  tags = {
    Name = "ansible-eda"
  }
}