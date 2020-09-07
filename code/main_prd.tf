# Provider
# provider "aws" {
#   profile = "gadkim"
#   region = var.region
# }

# VPC Resource
resource "aws_vpc" "main-prd" {
  cidr_block = "10.51.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform VPC-PRD"
  }
}