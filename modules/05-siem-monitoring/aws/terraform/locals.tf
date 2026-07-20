locals {
  name_prefix = "sdci-05-aws"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "aws"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name       = "${local.name_prefix}-vpc"
  snet_name      = "${local.name_prefix}-snet"
  igw_name       = "${local.name_prefix}-igw"
  sg_name        = "${local.name_prefix}-sg"
  log_group      = "${local.name_prefix}-flow-logs"
  metric_filter  = "${local.name_prefix}-ssh-attempts"
  alarm_name     = "${local.name_prefix}-high-ssh"
  sns_topic      = "${local.name_prefix}-alerts"
  instance_name  = "${local.name_prefix}-ec2"
}
