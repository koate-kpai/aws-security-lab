resource "null_resource" "cost_estimate" {
  triggers = {
    enable_nat    = var.enable_nat
    enable_bastion = var.enable_bastion
  }

  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 01: VPC Segmentation (AWS)       ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ VPC                             1     $0.00       Yes       ║
      ║ Subnets (3)                     3     $0.00       Yes       ║
      ║ Security Groups (3)             3     $0.00       Yes       ║
      ║ NACLs (2)                       2     $0.00       Yes       ║
      ║ Internet Gateway                1     $0.00       Yes       ║
      ║ NAT Gateway                     1     $1.08       No  ***   ║
      ║ Elastic IP                      1     $0.00       Yes       ║
      ║ t2.micro bastion                1     $0.00       Yes*      ║
      ║ Route tables (2)                2     $0.00       Yes       ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $1.08                 ║
      ║                                                              ║
      ║  *** NAT Gateway is NOT free tier eligible (~$32/month).     ║
      ║  * t2.micro is free tier eligible (750 hrs/month).           ║
      ║                                                              ║
      ║  Daily budget cap per lab: $1.00 — NAT alone exceeds this.   ║
      ║  SOLUTION: Run lab in a single session, destroy immediately. ║
      ║  2-hour session costs ~$0.09 (within $1 cap for the day).    ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
