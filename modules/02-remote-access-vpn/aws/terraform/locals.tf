locals {
  name_prefix = "sdci-02-aws"

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
  subnet_pub   = "${local.name_prefix}-subnet-pub"
  subnet_priv  = "${local.name_prefix}-subnet-priv"
  igw_name     = "${local.name_prefix}-igw"
  sg_vpn       = "${local.name_prefix}-sg-vpn"
  sg_workload  = "${local.name_prefix}-sg-workload"

  cvpn_endpoint    = "${local.name_prefix}-cvpn"
  cvpn_sg          = "${local.name_prefix}-cvpn-sg"
  server_cert_cn   = "server.${local.name_prefix}.example.com"
  client_cert_cn   = "client.${local.name_prefix}.example.com"

  workload_name    = "${local.name_prefix}-workload"
}
