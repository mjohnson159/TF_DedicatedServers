provider "aws" {
  region = local.region
}

locals {
  name   = "ec2-single-instance"
  region = "us-west-2"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 3.14.2"
  # insert the 23 required variables here
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 4.1.1"

  name = "single-instance"

  ami                    = "ami-01f14dc60171d8d7b" # Microsoft Windows Server 2019 Base
  instance_type          = "t2.small"
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = var.ec2_tags
}