terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

variable "region" {
  description = "AWS region to use for the example."
  type        = string
  default     = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

module "ssm_ec2" {
  source = "../../"

  name      = "example-ssm-instance"
  vpc_id    = data.aws_vpc.default.id
  subnet_id = data.aws_subnet_ids.default.ids[0]

  tags = {
    Environment = "demo"
  }
}
