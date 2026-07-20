# ------------------------------------------------------------------------------
# SDCI Lab 02 — Remote Access VPN (AWS)
# vpn.tf
#
# AWS CLIENT VPN — Remote Access for Hybrid Workers
#
# AWS Client VPN is a managed remote access VPN service. Individual users
# connect using the OpenVPN client, authenticate with certificates, and are
# granted access to specific networks via authorization rules.
#
# This maps directly to the SDCI 300-745 "Internet Edge" scenario where
# remote employees need secure access to internal corporate applications.
#
# ARCHITECTURE:
# 1. VPC with public subnet (Client VPN endpoint) and private subnet (workload)
# 2. Self-signed certificate chain for authentication
# 3. Client VPN endpoint in the public subnet
# 4. Authorization rules granting access to the private subnet
# 5. Workload instance in the private subnet
#
# COST: AWS Client VPN is free for the first 1,000 hours per month.
# After that: $0.10/hour. This lab runs well within the free tier.
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC and networking
# --------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = local.vpc_name })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags = merge(local.tags, { Name = local.subnet_pub })
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = merge(local.tags, { Name = local.subnet_priv })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = local.igw_name })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.tags, { Name = "${local.name_prefix}-rt-pub" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------------------------------
# TLS certificates (self-signed for lab use)
# Production should use ACM Private CA or a public CA.
# --------------------------------------------------------------------------
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name         = local.server_cert_cn
    organization        = "SDCI Lab"
    organizational_unit = "Training"
  }

  validity_period_hours = 8760  # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name         = local.client_cert_cn
    organization        = "SDCI Lab"
    organizational_unit = "Training"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.server.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.server.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# --------------------------------------------------------------------------
# ACM certificates (required by AWS Client VPN)
# --------------------------------------------------------------------------
resource "aws_acm_certificate" "server" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_self_signed_cert.server.cert_pem
  tags              = local.tags
}

resource "aws_acm_certificate" "client" {
  private_key       = tls_private_key.client.private_key_pem
  certificate_body  = tls_locally_signed_cert.client.cert_pem
  certificate_chain = tls_self_signed_cert.server.cert_pem
  tags              = local.tags
}

# --------------------------------------------------------------------------
# Security groups
# --------------------------------------------------------------------------
resource "aws_security_group" "vpn" {
  name        = local.cvpn_sg
  description = "Client VPN endpoint SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = local.cvpn_sg })
}

resource "aws_security_group" "workload" {
  name        = local.sg_workload
  description = "Workload instance SG — allow VPN traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.client_cidr]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.client_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = local.sg_workload })
}

# --------------------------------------------------------------------------
# Client VPN endpoint
# --------------------------------------------------------------------------
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "SDCI Lab 02 — Remote Access VPN"
  client_cidr_block      = var.client_cidr
  server_certificate_arn = aws_acm_certificate.server.arn

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.server.arn
  }

  connection_log_options {
    enabled = false
  }

  security_group_ids = [aws_security_group.vpn.id]

  vpc_id     = aws_vpc.main.id
  vpn_port   = 443
  transport_protocol = "udp"

  tags = merge(local.tags, { Name = local.cvpn_endpoint })
}

# Associate the Client VPN endpoint with the public subnet
resource "aws_ec2_client_vpn_network_association" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = aws_subnet.public.id
}

# Authorization rule — grant VPN users access to the private subnet
resource "aws_ec2_client_vpn_authorization_rule" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = aws_subnet.private.cidr_block
  authorize_all_groups   = true
  description            = "Grant VPN access to private subnet"
}

# --------------------------------------------------------------------------
# Routing — add route for private subnet through the VPN
# --------------------------------------------------------------------------
resource "aws_ec2_client_vpn_route" "main" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = aws_subnet.private.cidr_block
  target_vpc_subnet_id   = aws_subnet.public.id
  description            = "Route to private subnet via VPN"
}

# --------------------------------------------------------------------------
# Workload instance in private subnet
# --------------------------------------------------------------------------
resource "aws_instance" "workload" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.workload.id]

  associate_public_ip_address = false

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.tags, { Name = local.workload_name })
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
  owners = ["099720109477"]
}
