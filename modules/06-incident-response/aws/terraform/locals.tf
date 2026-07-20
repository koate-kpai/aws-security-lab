locals {
  name_prefix = "sdci-06-aws"
  mandatory_tags = {
    CostCenter = "SDCI-Lab"; Environment = "Training"; Module = var.module_name
    Cloud = "aws"; Creator = var.creator; DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)

  vpc_name          = "${local.name_prefix}-vpc"
  snet_name         = "${local.name_prefix}-snet"
  igw_name          = "${local.name_prefix}-igw"
  sg_normal         = "${local.name_prefix}-sg-normal"
  sg_quarantine     = "${local.name_prefix}-sg-quarantine"
  nacl_quarantine   = "${local.name_prefix}-nacl-quarantine"
  instance_clean    = "${local.name_prefix}-ec2-clean"
  instance_quar     = "${local.name_prefix}-ec2-quarantined"
}
