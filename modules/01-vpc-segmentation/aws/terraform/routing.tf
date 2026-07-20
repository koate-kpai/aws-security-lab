# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (AWS)
# routing.tf
#
# INTERNET GATEWAY, NAT GATEWAY, AND ROUTE TABLES
#
# GCP uses Cloud NAT for private egress; AWS uses NAT Gateway.
# The key difference: GCP Cloud NAT is regional and shared by all subnets.
# AWS NAT Gateway is per-AZ and costs $0.045/hour (~$1.08/day).
#
# COST WARNING:
# NAT Gateway is the most expensive resource in this module. It is NOT covered
# by the AWS free tier. At $0.045/hour, a 2-hour lab session costs $0.09.
# The enable_nat variable lets you skip it entirely if you don't need internet
# from private instances.
#
# ROUTE TABLE DESIGN:
# - Public route table: 0.0.0.0/0 → Internet Gateway
# - Private route table: 0.0.0.0/0 → NAT Gateway (if enabled)
# - No route between public and private subnets (segmented by design)
# ------------------------------------------------------------------------------

# Internet Gateway — for public subnet egress
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.tags, {
    Name = local.igw_name
  })
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat ? 1 : 0
  domain = "vpc"

  tags = merge(local.tags, {
    Name = local.nat_eip
  })
}

# NAT Gateway — for private subnet egress
resource "aws_nat_gateway" "main" {
  count = var.enable_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public.id

  tags = merge(local.tags, {
    Name = local.nat_name
  })

  # NAT Gateway depends on the IGW being available
  depends_on = [aws_internet_gateway.main]
}

# Public route table — Access Layer
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.tags, {
    Name = local.rt_public
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table — Distribution + Core Layers
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(local.tags, {
    Name = local.rt_private
  })
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
