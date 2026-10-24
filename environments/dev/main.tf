locals {
  name = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "vpc" {
  source = "../../modules/vpc"

  name = local.name
}

module "web" {
  source = "../../modules/ec2"

  name          = local.name
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_ids[0]
  instance_type = var.instance_type
}

module "artifacts_bucket" {
  source = "../../modules/s3"

  bucket_name = "${local.name}-artifacts-${random_id.suffix.hex}"
}
