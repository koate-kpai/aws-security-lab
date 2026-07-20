# SDCI Lab 06 — AWS: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\06-incident-response\aws\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — Verify Normal vs Quarantined

```bash
$cleanIp = $(terraform output -raw instance_clean_ip)
$quarIp  = $(terraform output -raw instance_quarantined_ip)

# Works
ssh -o ConnectTimeout=5 ec2-user@$cleanIp "echo ACCESSIBLE"

# TIMEOUT
ssh -o ConnectTimeout=5 ec2-user@$quarIp "echo BLOCKED"
```

## Step 3 — Dynamic Quarantine

```bash
$instanceId = $(terraform output -raw instance_clean_id)
$quarSgId   = $(terraform output -raw quarantine_sg_id)

# Quarantine
aws ec2 modify-instance-attribute --instance-id $instanceId --groups $quarSgId

# Verify blocked
ssh -o ConnectTimeout=5 ec2-user@$cleanIp "echo QUARANTINED"

# Release
$normSgId = $(terraform output -raw normal_sg_id)
aws ec2 modify-instance-attribute --instance-id $instanceId --groups $normSgId
```

## Step 4 — Cleanup

```powershell
.\cleanup.ps1
```
