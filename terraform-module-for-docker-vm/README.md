Terraform Module to provision an AWS EC2 instance with the latest amazon linux 2 ami and installed docker in it.

Not intended for production use. It is an example module.

It is just for showing how to create a publish module in Terraform Registry.

Usage:

```hcl

provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
    source = "<github-username>/docker-instance/aws"
    key_name = "clarusway"
}

Variables...

key_name                = **Required** Server Keypair name          **type = string

instance_type           = Aws ec2 type                              **type = string

num_of_instance         = Quantity of server                        **type = number

tag                     = Virtual docker server tag                 **type = string

server-name             = Virtual docker server name                **type = string

docker-instance-ports   = Security group inbound allowed ports      **type = list(number)