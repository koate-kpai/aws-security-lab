param(
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 01 — VPC Segmentation Cleanup (AWS)     ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Push-Location $modulePath
try {
    Write-Host "Resources managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null

    if (-not $AutoApprove) {
        Write-Host ""
        Write-Host "WARNING: This will destroy ALL resources in Lab 01." -ForegroundColor Red
        Write-Host "NAT Gateway (~$1.08/day) will be removed." -ForegroundColor Yellow
        $confirm = Read-Host "Type 'yes' to proceed"
        if ($confirm -ne "yes") { Write-Host "Cleanup cancelled." -ForegroundColor Green; return }
    }

    Write-Host "Running terraform destroy..." -ForegroundColor Yellow
    if ($AutoApprove) { & terraform destroy -auto-approve }
    else { & terraform destroy }

    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "`n=== Post-Cleanup Checklist ===" -ForegroundColor Cyan
    Write-Host "1. Check AWS Billing: https://console.aws.amazon.com/billing" -ForegroundColor White
    Write-Host "2. Verify no orphaned NAT Gateways:" -ForegroundColor White
    Write-Host "   aws ec2 describe-nat-gateways --filter Name=state,Values=pending,available" -ForegroundColor White
    Write-Host "3. Verify no orphaned resources via tags:" -ForegroundColor White
    Write-Host "   aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=SDCI-Lab" -ForegroundColor White
}
finally { Pop-Location }
