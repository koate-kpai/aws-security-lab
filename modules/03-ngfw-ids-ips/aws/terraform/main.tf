# ------------------------------------------------------------------------------
# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (AWS)
# main.tf
#
# Three security layers:
#   1. AWS WAF — Layer 7 web application firewall
#   2. Security Groups + NACLs — Zone-based segmentation
#   3. GuardDuty — Network threat detection
#
# ARCHITECTURE:
#   Internet → WAF → ALB → Web subnet → App subnet (SG/NACL enforced)
#                                └─ GuardDuty monitors VPC Flow Logs
#
# COST: WAF (free tier: 5 ACLs), GuardDuty (30-day free trial),
#        ALB (~$0.0225/hr = $0.54/day), SGs/NACLs (free).
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# VPC and subnets
# --------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.tags, { Name = local.vpc_name })
}

resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = false
  tags = merge(local.tags, { Name = local.snet_web, Tier = "web" })
}

resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = merge(local.tags, { Name = local.snet_app, Tier = "app" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = local.igw_name })
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.tags, { Name = "${local.name_prefix}-rt-web" })
}

resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.web.id
}

# --------------------------------------------------------------------------
# SECURITY GROUPS — Instance-level firewall
# --------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = local.sg_web
  description = "Web tier SG — allows HTTP from ALB only"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

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
  tags = merge(local.tags, { Name = local.sg_web })
}

resource "aws_security_group" "app" {
  name        = local.sg_app
  description = "App tier SG — allows HTTP from web SG only (micro-segmentation)"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = local.sg_app })
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "ALB SG — allows HTTP from internet, passes to WAF"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.tags, { Name = "${local.name_prefix}-sg-alb" })
}

# --------------------------------------------------------------------------
# NACLs — Subnet-level stateless firewall (simulates distribution ACLs)
# --------------------------------------------------------------------------
resource "aws_network_acl" "web" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.web.id]
  tags       = merge(local.tags, { Name = local.nacl_web })
}

resource "aws_network_acl_rule" "web_ingress_http" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "web_egress_all" {
  network_acl_id = aws_network_acl.web.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "app" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.app.id]
  tags       = merge(local.tags, { Name = local.nacl_app })
}

resource "aws_network_acl_rule" "app_ingress_web" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "10.0.1.0/24"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "app_ingress_ephemeral" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "app_egress_all" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# --------------------------------------------------------------------------
# GUARDDUTY — Threat detection (30-day free trial)
# Enables GuardDuty to monitor VPC Flow Logs and CloudTrail for threats.
# --------------------------------------------------------------------------
resource "aws_guardduty_detector" "main" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
  tags                         = local.tags
}

# --------------------------------------------------------------------------
# WAF WEB ACL — Layer 7 protection
# Free tier: 5 web ACLs, 1,000 rules. We use 3 rules within free tier.
# --------------------------------------------------------------------------
resource "wafv2_ip_set" "allowlist" {
  name               = "${local.name_prefix}-allowlist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = []
  tags               = local.tags
}

resource "aws_wafv2_web_acl" "main" {
  name        = local.waf_acl
  description = "SDCI Lab 03 — WAF blocking SQLi, XSS, and common exploits"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: Block SQL injection
  rule {
    name     = "Block-SQL-Injection"
    priority = 1
    action { block {} }
    statement {
      sqli_match_statement {
        field_to_match { body {} }
        text_transformation { priority = 0; type = "URL_DECODE" }
        text_transformation { priority = 1; type = "HTML_ENTITY_DECODE" }
      }
    }
    visibility_config { cloudwatch_metrics_enabled = true; metric_name = "BlockSQLInjection"; sampled_requests_enabled = true }
  }

  # Rule 2: Block XSS
  rule {
    name     = "Block-XSS"
    priority = 2
    action { block {} }
    statement {
      xss_match_statement {
        field_to_match { body {} }
        text_transformation { priority = 0; type = "URL_DECODE" }
        text_transformation { priority = 1; type = "HTML_ENTITY_DECODE" }
      }
    }
    visibility_config { cloudwatch_metrics_enabled = true; metric_name = "BlockXSS"; sampled_requests_enabled = true }
  }

  # Rule 3: Rate-based blocking (mitigates DDoS)
  rule {
    name     = "Rate-Limit"
    priority = 3
    action { block {} }
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    visibility_config { cloudwatch_metrics_enabled = true; metric_name = "RateLimit"; sampled_requests_enabled = true }
  }

  visibility_config { cloudwatch_metrics_enabled = true; metric_name = "SDCI-WAF"; sampled_requests_enabled = true }
  tags = local.tags
}

# --------------------------------------------------------------------------
# APPLICATION LOAD BALANCER + WAF Association
# --------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.web.id]
  tags               = local.tags
}

resource "aws_lb_target_group" "main" {
  name     = local.alb_tg
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    path = "/"
  }
  tags = local.tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# Launch template and auto scaling group
resource "aws_launch_template" "main" {
  name          = local.lt_name
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<html><body><h1>SDCI Lab 03 — Protected by AWS WAF</h1><p>Instance: $(hostname)</p></body></html>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, { Name = "${local.name_prefix}-web" })
  }
}

resource "aws_autoscaling_group" "main" {
  name               = local.asg_name
  desired_capacity   = 1
  min_size           = 1
  max_size           = 2
  target_group_arns  = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = [aws_subnet.web.id]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-web"
    propagate_at_launch = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter { name = "virtualization-type"; values = ["hvm"] }
  owners = ["099720109477"]
}
