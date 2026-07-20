# ------------------------------------------------------------------------------
# SDCI Lab 04 — Zero Trust & Identity Access Management (AWS)
# main.tf
#
# Key concepts demonstrated:
#   1. Workload identity — IAM Role + Instance Profile on EC2
#   2. Least-privilege IAM — Custom policy with minimal permissions
#   3. Permission boundary — Restricts maximum permissions the role can have
#   4. Zero-trust access — SSM Session Manager instead of SSH
#   5. Policy-as-Code — All IAM defined in Terraform
#
# ARCHITECTURE:
#   Developer → AWS SSM (Zero Trust) → EC2 → IAM Role reads S3
# COST: SSM free, EC2 t2.micro free tier (750 hrs/mo), S3/IAM free
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC — public subnet (instance has public IP but no open ports)
# --------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = local.vpc_name })
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = local.snet_name })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = local.igw_name })
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.tags, { Name = "${local.name_prefix}-rt" })
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# --------------------------------------------------------------------------
# SECURITY GROUP — defaults to deny all inbound
# Zero Trust: no SSH port (22) open; SSM Session Manager only
# --------------------------------------------------------------------------
resource "aws_security_group" "main" {
  name        = local.sg_name
  description = "Deny all inbound — access via SSM Session Manager only"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = local.sg_name })
}

# --------------------------------------------------------------------------
# S3 BUCKET — resource for least-privilege access demonstration
# --------------------------------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket        = "${local.bucket_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

# --------------------------------------------------------------------------
# IAM PERMISSION BOUNDARY — restricts maximum permissions
# Even if the role is granted more permissions later, the boundary caps it
# --------------------------------------------------------------------------
resource "aws_iam_policy" "boundary" {
  name        = local.boundary_name
  description = "Permission boundary: allows EC2 + SSM + S3 read-only only"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ssm:*",
          "s3:Get*",
          "s3:List*",
        ]
        Resource = "*"
      },
    ]
  })
  tags = local.tags
}

# --------------------------------------------------------------------------
# CUSTOM IAM POLICY — least privilege for the workload role
# Only read-only access to the specific S3 bucket
# --------------------------------------------------------------------------
resource "aws_iam_policy" "main" {
  name        = local.policy_name
  description = "Least-privilege policy: read objects in ${aws_s3_bucket.main.id}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*",
        ]
      },
    ]
  })
  tags = local.tags
}

# --------------------------------------------------------------------------
# IAM ROLE — workload identity for EC2
# Permission boundary + custom policy together enforce least privilege
# --------------------------------------------------------------------------
resource "aws_iam_role" "main" {
  name                 = local.role_name
  description          = "SDCI Lab 04 — EC2 workload identity with least privilege"
  permissions_boundary = aws_iam_policy.boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
  tags = local.tags
}

# Attach the least-privilege policy
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# Attach AWS SSM managed policy for Session Manager access
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --------------------------------------------------------------------------
# INSTANCE PROFILE — binds the role to EC2
# --------------------------------------------------------------------------
resource "aws_iam_instance_profile" "main" {
  name = local.profile_name
  role = aws_iam_role.main.name
  tags = local.tags
}

# --------------------------------------------------------------------------
# EC2 INSTANCE — workload identity via instance profile
# Uses Amazon Linux 2 (SSM Agent pre-installed)
# --------------------------------------------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter { name = "virtualization-type"; values = ["hvm"] }
  owners = ["137112412989"]
}

resource "aws_instance" "main" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]
  iam_instance_profile   = aws_iam_instance_profile.main.name
  monitoring             = true
  tags                   = merge(local.tags, { Name = local.instance_name })
}
