# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (AWS)
# vpc.tf
#
# THREE-TIER VPC DESIGN
#
# AWS maps naturally to the Cisco three-tier model because of its explicit
# public/private subnet architecture:
#   Public subnet  (10.0.1.0/24)  = Access Layer (bastion, end-users)
#   Private subnet (10.0.2.0/24)  = Distribution Layer (policy enforcement)
#   Private subnet (10.0.3.0/24)  = Core Layer (backend, NAT placement)
#
# The Internet Gateway provides public subnet access. The NAT Gateway provides
# private subnet egress. NACLs enforce subnet-level boundaries.
# ------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.ip_ranges.vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}

# Public subnet = Access Layer (bastion host, user-facing services)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ip_ranges.public
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = merge(local.tags, {
    Name = local.subnet_public
    Tier = "access"
  })
}

# Private subnet A = Distribution Layer (policy boundary, inter-zone routing)
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ip_ranges.private_a
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = merge(local.tags, {
    Name = local.subnet_private_a
    Tier = "distribution"
  })
}

# Private subnet B = Core Layer (backend services, NAT Gateway)
resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.ip_ranges.private_b
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}a"

  tags = merge(local.tags, {
    Name = local.subnet_private_b
    Tier = "core"
  })
}
