# Cleanup script for SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (AWS)
# Run from the terraform/ directory.

param(
    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"
$confirm = $AutoApprove -or ((Read-Host "Destroy all resources? (yes/no)") -eq "yes")
if (-not $confirm) { Write-Host "Aborted."; exit }

# Terraform destroy
terraform destroy -auto-approve

Write-Host "Cleanup complete. All resources for Module 03 (AWS) have been removed."
