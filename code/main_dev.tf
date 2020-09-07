# Provider
provider "aws" {
  region = var.region
}

# VPC Resource
resource "aws_vpc" "main-dev" {
  cidr_block = "10.11.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC-DEV"
  }
}