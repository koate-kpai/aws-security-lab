param([switch]$AutoApprove = $false)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 02 — Remote Access VPN Cleanup (AWS)    ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Push-Location $modulePath
try {
    & terraform state list 2>$null
    if (-not $AutoApprove) {
        $confirm = Read-Host "Type 'yes' to destroy"
        if ($confirm -ne "yes") { return }
    }
    & terraform destroy -auto-approve
    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "Check: aws ec2 describe-client-vpn-endpoints" -ForegroundColor White
}
finally { Pop-Location }
