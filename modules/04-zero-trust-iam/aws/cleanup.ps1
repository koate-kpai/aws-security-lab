# Cleanup script for SDCI Lab 04 — Zero Trust & IAM (AWS)
# Run from the terraform/ directory.

param(
    [switch]$AutoApprove
)

$ErrorActionPreference = "Stop"
$confirm = $AutoApprove -or ((Read-Host "Destroy all resources? (yes/no)") -eq "yes")
if (-not $confirm) { Write-Host "Aborted."; exit }

terraform destroy -auto-approve

Write-Host "Cleanup complete. All resources for Module 04 (AWS) have been removed."
