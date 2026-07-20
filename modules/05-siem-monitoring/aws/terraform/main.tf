# ------------------------------------------------------------------------------
# SDCI Lab 05 — SIEM, Monitoring & UEBA (AWS)
# main.tf
#
# Key concepts demonstrated:
#   1. VPC Flow Logs — network traffic monitoring to CloudWatch
#   2. CloudWatch Logs — centralized log storage
#   3. Metric Filters — extract metrics from log data
#   4. CloudWatch Alarms — threshold-based alerting
#   5. Security Hub — cross-service security findings
#
# ARCHITECTURE:
#   Traffic → VPC Flow Logs → CloudWatch Logs → Metric Filter → Alarm → SNS
# COST: Flow Logs minimal, CloudWatch free tier, Security Hub 30-day trial
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC — public subnet with SSH access (for generating log entries)
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

resource "aws_security_group" "main" {
  name        = local.sg_name
  description = "Allow SSH from anywhere (for monitoring pipeline)"
  vpc_id      = aws_vpc.main.id

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
  tags = merge(local.tags, { Name = local.sg_name })
}

# --------------------------------------------------------------------------
# VPC FLOW LOGS — published to CloudWatch Logs
# --------------------------------------------------------------------------
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.main.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  max_aggregation_interval = 60
  tags            = local.tags
}

resource "aws_cloudwatch_log_group" "main" {
  name              = local.log_group
  retention_in_days = 7
  tags              = local.tags
}

# IAM role for VPC Flow Logs to publish to CloudWatch
resource "aws_iam_role" "flow_logs" {
  name = "${local.name_prefix}-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${local.name_prefix}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
      ]
      Resource = "*"
    }]
  })
}

# --------------------------------------------------------------------------
# EC2 INSTANCE — generates SSH log traffic
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
  monitoring             = true
  tags                   = merge(local.tags, { Name = local.instance_name })
}

# --------------------------------------------------------------------------
# CLOUDWATCH METRIC FILTER — extract SSH attempt count from flow logs
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "ssh_attempts" {
  name           = local.metric_filter
  pattern        = "[version, account_id, interface_id, src_addr, dst_addr, src_port, dst_port=22, protocol=6, packets, bytes, start, end, action, log_status]"
  log_group_name = aws_cloudwatch_log_group.main.name

  metric_transformation {
    name      = "SSHAttempts"
    namespace = "SDCI/Lab05"
    value     = "1"
  }
}

# --------------------------------------------------------------------------
# CLOUDWATCH ALARM — fires when SSH attempts exceed threshold
# --------------------------------------------------------------------------
resource "aws_sns_topic" "alerts" {
  name = local.sns_topic
  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "high_ssh" {
  alarm_name          = local.alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SSHAttempts"
  namespace           = "SDCI/Lab05"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "High number of SSH connection attempts detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  tags                = local.tags
}

# --------------------------------------------------------------------------
# SECURITY HUB — cross-service security findings dashboard (30-day trial)
# --------------------------------------------------------------------------
resource "aws_securityhub_account" "main" {}
