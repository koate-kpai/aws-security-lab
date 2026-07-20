# SDCI Lab 07 — AWS: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\07-dlp-endpoint\aws\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — View Macie Findings

```bash
# List findings
aws macie2 list-findings

# Get finding details (replace with actual finding-id)
aws macie2 get-finding --finding-id <id> --query "finding.description"
```

## Step 3 — Macie Console

Navigate to **Macie** in the AWS Console.

- Check the **Summary** dashboard for bucket counts and sensitive data totals
- View **Findings** for the classification job results
- Compare the sensitive bucket (findings expected) vs clean bucket (no findings)

## Step 4 — Verify Data Content

```bash
# View the sensitive data file
aws s3 cp s3://$(terraform output -raw sensitive_bucket)/data/customers.csv -

# View the clean file
aws s3 cp s3://$(terraform output -raw clean_bucket)/readme.txt -
```

## Step 5 — Cleanup

```powershell
.\cleanup.ps1
```
