param(
    [Parameter(Mandatory = $false)]
    [string]$ModulePath = ".",
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

<#
.SYNOPSIS
    Universal cleanup script for AWS Security Lab modules.
.DESCRIPTION
    Destroys all Terraform-managed resources in the module, prints a cost
    summary, and reminds the user to check for orphaned resources.
.EXAMPLE
    .\cleanup.ps1 -ModulePath "modules/01-vpc-segmentation/aws/terraform" -AutoApprove
#>

function Write-WarningBanner {
    Write-Host "`n============================================" -ForegroundColor Yellow
    Write-Host "   SDCI AWS Security Lab — Cleanup"         -ForegroundColor Yellow
    Write-Host "============================================`n" -ForegroundColor Yellow
}

function Get-ResourceSummary {
    param([string]$StateDir)
    Write-Host "Resources currently managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null | ForEach-Object { Write-Host "  $_" }
}

function Invoke-TerraformDestroy {
    param([string]$Dir, [bool]$AutoApprove)
    Push-Location $Dir
    try {
        if ($AutoApprove) {
            terraform destroy -auto-approve
        } else {
            Read-Host "Press ENTER to proceed with destruction (Ctrl+C to abort)"
            terraform destroy -auto-approve
        }
    }
    finally {
        Pop-Location
    }
}

function Show-PostCleanupInstructions {
    Write-Host "`n=== Post-Cleanup Checklist ===" -ForegroundColor Green
    Write-Host "  1. Check AWS Billing: https://console.aws.amazon.com/billing" -ForegroundColor White
    Write-Host "  2. Verify no orphaned NAT Gateways (most common cost leak):" -ForegroundColor White
    Write-Host "     aws ec2 describe-nat-gateways --filters Name=state,Values=pending,available" -ForegroundColor White
    Write-Host "  3. Verify no orphaned resources via AWS Config" -ForegroundColor White
    Write-Host "  4. Remove local state: Remove-Item -Recurse -Force .terraform/`n" -ForegroundColor White
}

# --- Main ---
Write-WarningBanner
$targetDir = Resolve-Path $ModulePath
Write-Host "Module: $targetDir`n" -ForegroundColor Cyan

Get-ResourceSummary -StateDir $targetDir

Write-Host "`nWARNING: This will DESTROY all resources in this module." -ForegroundColor Red -BackgroundColor Black
Write-Host "AWS NAT Gateways and non-free-tier resources will be removed.`n" -ForegroundColor Yellow

Invoke-TerraformDestroy -Dir $targetDir -AutoApprove $AutoApprove
Show-PostCleanupInstructions
