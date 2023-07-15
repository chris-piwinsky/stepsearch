data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "domain" {
  name         = var.domain_name
  private_zone = false
}

data "aws_vpc" "production_vpc" {
  tags = {
    Name = "project-production-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["*private*"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.production_vpc.id]
  }
}

data "archive_file" "extract" {
  type        = "zip"
  source_dir  = "./files/extract"
  output_path = "./files/extract_function.zip"
}

data "archive_file" "transform" {
  type        = "zip"
  source_dir  = "./files/transform"
  output_path = "./files/transform_function.zip"
}

data "archive_file" "load" {
  type        = "zip"
  source_dir  = "./files/load"
  output_path = "./files/load_function.zip"
}