locals {
  name_prefix = "sdci-07-aws"
  mandatory_tags = {
    CostCenter = "SDCI-Lab"; Environment = "Training"; Module = var.module_name; Cloud = "aws"
    Creator = var.creator; DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)
}
