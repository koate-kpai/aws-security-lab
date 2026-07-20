# AWS Incident Response — Quarantine/Release an EC2 instance by swapping SG
param(
    [Parameter(Mandatory = $true)][string]$InstanceId,
    [ValidateSet("quarantine", "release")][string]$Action
)
$ErrorActionPreference = "Stop"

# Fetch SG IDs from Terraform output
$quarantineSg = $(terraform output -raw quarantine_sg_id)
$normalSg = $(terraform output -raw normal_sg_id)

if ($Action -eq "quarantine") {
    Write-Host "🔒 Quarantining $InstanceId by swapping to deny-all SG..."
    aws ec2 modify-instance-attribute --instance-id $InstanceId --groups $quarantineSg
    Write-Host "Done. Instance quarantined (deny-all SG active)."
}
else {
    Write-Host "🔓 Releasing $InstanceId by restoring normal SG..."
    aws ec2 modify-instance-attribute --instance-id $InstanceId --groups $normalSg
    Write-Host "Done. Normal network access restored."
}
