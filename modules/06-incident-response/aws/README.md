# SDCI Lab 06 — Incident Response & Containment (AWS)

Quarantine a compromised EC2 instance by swapping its Security Group. For SDCI 300-745.

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Test

```bash
# 1. SSH to clean instance — works
ssh -o StrictHostKeyChecking=no ec2-user@$(terraform output -raw instance_clean_ip)

# 2. SSH to quarantined instance — TIMEOUT (deny-all SG)
ssh -o ConnectTimeout=5 ec2-user@$(terraform output -raw instance_quarantined_ip)

# 3. Quarantine the clean instance dynamically
aws ec2 modify-instance-attribute --instance-id $(terraform output -raw instance_clean_id) --groups $(terraform output -raw quarantine_sg_id)

# 4. SSH — TIMEOUT (now quarantined)

# 5. Release
aws ec2 modify-instance-attribute --instance-id $(terraform output -raw instance_clean_id) --groups $(terraform output -raw normal_sg_id)
```

## Cost

~$0.00/day (t2.micro free tier).

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
