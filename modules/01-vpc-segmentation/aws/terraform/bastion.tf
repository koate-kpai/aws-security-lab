# ------------------------------------------------------------------------------
# SDCI Lab 01 — VPC Segmentation (AWS)
# bastion.tf
#
# BASTION HOST
#
# A t2.micro EC2 instance in the public subnet that serves as the
# administrative entry point into the private subnets.
#
# DECISION: Bastion vs. Systems Manager Session Manager
# AWS Systems Manager Session Manager provides browser-based shell access
# without a bastion. We include a bastion here because:
#   1. It mirrors the typical enterprise pattern tested in SDCI 300-745
#   2. Session Manager requires the SSM agent and IAM role configuration
#   3. The bastion demonstrates SSH agent forwarding patterns
#
# COST: t2.micro is free tier eligible (750 hours/month). If you've used your
# free tier hours, this instance will cost ~$0.0116/hour.
#
# SECURITY: The bastion has a public IP for SSH access. In production, use
# a private instance with Session Manager or a VPN.
# ------------------------------------------------------------------------------

# SSH key pair for bastion access
resource "aws_key_pair" "bastion" {
  count      = var.enable_bastion ? 1 : 0
  key_name   = local.keypair_name
  public_key = var.bastion_public_key

  tags = merge(local.tags, {
    Name = local.keypair_name
  })
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.bastion[0].key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.tags, {
    Name = local.bastion_name
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}
