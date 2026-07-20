locals {
  name_prefix = "sdci-04-aws"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "aws"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name        = "${local.name_prefix}-vpc"
  snet_name       = "${local.name_prefix}-snet"
  igw_name        = "${local.name_prefix}-igw"
  sg_name         = "${local.name_prefix}-sg"
  role_name       = "${local.name_prefix}-role"
  policy_name     = "${local.name_prefix}-policy"
  boundary_name   = "${local.name_prefix}-boundary"
  profile_name    = "${local.name_prefix}-instance-profile"
  bucket_name     = "${local.name_prefix}-bucket"
  instance_name   = "${local.name_prefix}-ec2"
}
