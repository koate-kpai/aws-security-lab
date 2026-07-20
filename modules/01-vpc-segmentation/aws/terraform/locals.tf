locals {
  name_prefix = "sdci-01-aws"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "aws"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name    = "${local.name_prefix}-vpc"
  igw_name    = "${local.name_prefix}-igw"
  nat_name    = "${local.name_prefix}-nat"
  nat_eip     = "${local.name_prefix}-nat-eip"

  subnet_public    = "${local.name_prefix}-subnet-public"
  subnet_private_a = "${local.name_prefix}-subnet-private-dist"
  subnet_private_b = "${local.name_prefix}-subnet-private-core"

  sg_bastion = "${local.name_prefix}-sg-bastion"
  sg_private = "${local.name_prefix}-sg-private"
  sg_core    = "${local.name_prefix}-sg-core"

  nacl_public  = "${local.name_prefix}-nacl-public"
  nacl_private = "${local.name_prefix}-nacl-private"

  rt_public  = "${local.name_prefix}-rt-public"
  rt_private = "${local.name_prefix}-rt-private"

  bastion_name = "${local.name_prefix}-bastion"
  bastion_sg   = "${local.name_prefix}-sg-bastion"
  keypair_name = "${local.name_prefix}-key"
}
