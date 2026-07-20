resource "null_resource" "cost_estimate" {
  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 02: Remote Access VPN (AWS)      ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ VPC + subnets (2)              1     $0.00       Yes       ║
      ║ Internet Gateway               1     $0.00       Yes       ║
      ║ Client VPN endpoint            1     $0.00       Yes*      ║
      ║ ACM certificates (2)           2     $0.00       Yes       ║
      ║ t2.micro workload              1     $0.00       Yes       ║
      ║ Security Groups (2)            2     $0.00       Yes       ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $0.00                 ║
      ║                                                              ║
      ║  * Client VPN: 1,000 hrs/month free. After that: $0.10/hr.  ║
      ║                                                              ║
      ║  Daily budget cap: $1.00 — you are at $0.00.                ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
