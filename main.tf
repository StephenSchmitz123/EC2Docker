terraform {
  required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
  }
}

module "EC2" {
    source = "./EC2"
}