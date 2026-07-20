# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (AWS)
# security_groups.tf
#
# SECURITY GROUPS (Instance-level firewall)
#
# Security Groups are stateful and operate at the instance level. They are the
# AWS equivalent of GCP firewall tags — you assign an SG to an ENI and that
# instance follows the SG rules.
#
# RULE HIERARCHY:
# SG rules are allow-only (no deny). To block traffic, you don't include an
# allow rule. We use NACLs (in nacl.tf) for explicit deny at the subnet level.
#
# DESIGN:
# - Bastion SG: allows SSH from IAP-equivalent (or 0.0.0.0/0 for learning)
# - Private SG: allows SSH from Bastion SG only (security group reference)
# - Core SG: allows inbound only from Private SG (distribution → core)
#
# Security group references (source_sg) are superior to CIDR-based rules because
# they automatically follow instances — if you add a new bastion, it can SSH
# without updating firewall rules.
# ------------------------------------------------------------------------------

# Bastion Security Group — allows SSH from the internet (or a restricted range)
resource "aws_security_group" "bastion" {
  name        = local.sg_bastion
  description = "Bastion host SG — allows SSH inbound from controlled sources"
  vpc_id      = aws_vpc.main.id

  # SSH from anywhere (for lab convenience). In production, restrict to your office IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = local.sg_bastion
  })
}

# Private Distribution Security Group — allows SSH from Bastion SG
resource "aws_security_group" "private" {
  name        = local.sg_private
  description = "Distribution layer SG — allows SSH from bastion, HTTP from bastion"
  vpc_id      = aws_vpc.main.id

  # SSH from bastion only (security group reference — follows the bastion)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # ICMP from bastion (for ping testing)
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = local.sg_private
  })
}

# Core Security Group — allows SSH from Distribution SG only
resource "aws_security_group" "core" {
  name        = local.sg_core
  description = "Core layer SG — allows SSH from distribution layer only (lateral movement prevention)"
  vpc_id      = aws_vpc.main.id

  # SSH from distribution only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.private.id]
  }

  # ICMP from distribution only
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.private.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = local.sg_core
  })
}
