# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (AWS)
# nacl.tf
#
# NETWORK ACLs (Subnet-level firewall)
#
# NACLs are stateless and operate at the subnet boundary. They complement
# Security Groups by providing a second layer of defense and supporting
# explicit DENY rules (which SGs cannot do).
#
# DESIGN PRINCIPLE:
# We apply separate NACLs to the public subnet (Access) and private subnets
# (Distribution + Core). This enforces zone-level isolation — even if an SG
# misconfiguration allows traffic, the NACL at the subnet boundary blocks it.
#
# COST: NACLs are free in AWS. No charge applies.
# ------------------------------------------------------------------------------

# Public subnet NACL — Access Layer
# Allows SSH from internet, allows all outbound. Blocks access-tier→core traffic.
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public.id]

  tags = merge(local.tags, {
    Name = local.nacl_public
  })
}

resource "aws_network_acl_rule" "public_ingress_ssh" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "public_ingress_ephemeral" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "public_egress_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Private subnet NACL — Distribution + Core Layers
# Restrictive: allows SSH only from public (bastion) subnet, blocks all other inbound.
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(local.tags, {
    Name = local.nacl_private
  })
}

resource "aws_network_acl_rule" "private_ingress_ssh" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.ip_ranges.public
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "private_ingress_internal" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.ip_ranges.private_a
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_ingress_internal_b" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 111
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.ip_ranges.private_b
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "private_ingress_ephemeral" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_egress_all" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
