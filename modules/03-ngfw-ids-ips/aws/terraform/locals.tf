locals {
  name_prefix = "sdci-03-aws"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "aws"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name     = "${local.name_prefix}-vpc"
  snet_web     = "${local.name_prefix}-snet-web"
  snet_app     = "${local.name_prefix}-snet-app"
  igw_name     = "${local.name_prefix}-igw"

  sg_web       = "${local.name_prefix}-sg-web"
  sg_app       = "${local.name_prefix}-sg-app"
  nacl_web     = "${local.name_prefix}-nacl-web"
  nacl_app     = "${local.name_prefix}-nacl-app"

  waf_acl      = "${local.name_prefix}-waf"
  waf_ipset    = "${local.name_prefix}-waf-ipset"

  alb_name     = "${local.name_prefix}-alb"
  alb_tg       = "${local.name_prefix}-tg"

  lt_name      = "${local.name_prefix}-lt"
  asg_name     = "${local.name_prefix}-asg"
}
