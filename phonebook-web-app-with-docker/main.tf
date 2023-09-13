terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Configure the GitHub Provider
provider "github" {
  token = "XxXXxXXxXXxXXxXXxXXxXXxXXxXXxXXxXXxX"
}

resource "github_repository" "docker-repo" {
  name        = "dockerportfolio-repo"
  description = "My awesome codebase"
  auto_init   = true
  visibility  = "private"
}

resource "github_branch_default" "docker-repo" {
  branch     = "main"
  repository = github_repository.docker-repo.name
}

variable "files" {
  default = ["bookstore-api.py", "requirements.txt", "Dockerfile", "docker-compose.yml"]
}
resource "github_repository_file" "app-files" {
  for_each            = toset(var.files)
  content             = file(each.value)
  file                = each.value
  repository          = github_repository.docker-repo.name
  branch              = "main"
  commit_message      = "managed by onur"
  overwrite_on_create = true
}

resource "aws_instance" "tf-docker-ec2" {
  ami                    = "ami-00c39f71452c08778"
  instance_type          = "t2.micro"
  key_name               = "Onur"
  vpc_security_group_ids = [aws_security_group.tf-docker-sec-gr.id]
  tags = {
    Name = "Bookstore Web Server"
  }
  depends_on = [github_repository.docker-repo, github_repository_file.app-files]
  user_data   = <<-EOF
        #!/bin/bash
        yum update -y
        yum install docker -y
        systemctl start docker
        systemctl enable docker
        usermod -a -G docker ec2-user
        newgrp docker
        curl -SL https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        mkdir -p /home/ec2-user/bookstore-api
        TOKEN="XxXXxXXxXXxXXxXXxXXxXXxXXxXXxXXxXXxX"
        FOLDER="https://$TOKEN@raw.githubusercontent.com/ompayat/dockerportfolio-repo/main/"
        curl -s --create-dirs -o "/home/ec2-user/bookstore-api/bookstore-api.py" -L "$FOLDER"bookstore-api.py
        curl -s --create-dirs -o "/home/ec2-user/bookstore-api/requirements.txt" -L "$FOLDER"requirements.txt
        curl -s --create-dirs -o "/home/ec2-user/bookstore-api/Dockerfile" -L "$FOLDER"Dockerfile
        curl -s --create-dirs -o "/home/ec2-user/bookstore-api/docker-compose.yml" -L "$FOLDER"docker-compose.yml
        cd /home/ec2-user/bookstore-api
        docker-compose up -d
  EOF
}

resource "aws_security_group" "tf-docker-sec-gr" {
  name = "docker-sec-gr-203-onur"
  tags = {
    Name = "docker-sec-group-203"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "website" {
  value = "http://${aws_instance.tf-docker-ec2.public_dns}"

}
