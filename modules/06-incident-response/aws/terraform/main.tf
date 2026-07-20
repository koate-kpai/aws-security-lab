# ------------------------------------------------------------------------------
# SDCI Lab 06 — Incident Response & Containment (AWS)
# main.tf
#
# Key concept: Quarantine an EC2 instance by swapping its Security Group
# to a "deny all" group, or applying a deny-all NACL at the subnet level.
#
# Incident Response workflow:
#   1. Detect compromise (GuardDuty, CloudWatch, etc.)
#   2. Quarantine via SG swap: modify-instance-attribute --groups <quarantine-sg-id>
#   3. Quarantine via NACL (subnet-level) — blocks all traffic in/out
#   4. Investigate via SSM Session Manager (if SSM pre-authorized)
#   5. Release: restore original SG
#
# COST: ~$0.00/day (all free tier eligible)
# --------------------------------------------------------------------------

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true; enable_dns_hostnames = true
  tags = merge(local.tags, { Name = local.vpc_name })
}

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id; cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = local.snet_name })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id; tags = merge(local.tags, { Name = local.igw_name })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0"; gateway_id = aws_internet_gateway.main.id }
  tags = merge(local.tags, { Name = "${local.name_prefix}-rt" })
}

resource "aws_route_table_association" "main" {
  subnet_id = aws_subnet.main.id; route_table_id = aws_route_table.main.id
}

# --------------------------------------------------------------------------
# SECURITY GROUPS — normal vs quarantine
# --------------------------------------------------------------------------

# Normal SG — allows SSH
resource "aws_security_group" "normal" {
  name        = local.sg_normal
  description = "Normal — allows SSH from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = local.sg_normal })
}

# Quarantine SG — denies all inbound and outbound
resource "aws_security_group" "quarantine" {
  name        = local.sg_quarantine
  description = "QUARANTINE — deny all traffic (isolation)"
  vpc_id      = aws_vpc.main.id

  # No ingress rules = deny all inbound
  # No egress rules = deny all outbound (no default allow)
  tags = merge(local.tags, { Name = local.sg_quarantine })
}

# --------------------------------------------------------------------------
# NACL — subnet-level quarantine (deny all)
# NACLs are stateless and evaluated before SGs
# --------------------------------------------------------------------------
resource "aws_network_acl" "quarantine" {
  vpc_id = aws_vpc.main.id; tags = merge(local.tags, { Name = local.nacl_quarantine })
  # No rules = deny all traffic (default deny)
}

# --------------------------------------------------------------------------
# EC2 INSTANCES — clean vs pre-quarantined
# --------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter { name = "name"; values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
  owners = ["137112412989"]
}

resource "aws_instance" "clean" {
  ami = data.aws_ami.amazon_linux.id; instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.normal.id]
  monitoring = true
  tags = merge(local.tags, { Name = local.instance_clean })
}

resource "aws_instance" "quarantined" {
  ami = data.aws_ami.amazon_linux.id; instance_type = "t2.micro"
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.quarantine.id]
  monitoring = true
  tags = merge(local.tags, { Name = local.instance_quar })
}
