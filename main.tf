terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
  }
}

module "VPC" {
    source = "./VPC"
}

module "EC2" {
    source = "./EC2"
    vpc_id = module.VPC.vpc_id
    subnet_id = module.VPC.subnet_id
}