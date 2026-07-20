# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (AWS)

DLP lab using Amazon Macie to discover and classify sensitive data in S3. For SDCI 300-745.

## Architecture

```
Sample PII (customers.csv) → S3 (sensitive bucket) → Macie Classification Job → Findings
Clean data (readme.txt)   → S3 (clean bucket)
```

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Test

```bash
# Check Macie findings (Console or CLI)
aws macie2 list-findings

# View individual finding
aws macie2 get-finding --id <finding-id>

# Compare — clean bucket should have zero findings
```

## Cost

Macie 30-day free trial. S3 minimal.

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
