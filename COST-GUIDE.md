# AWS Security Lab — Cost Guide

## FinOps Principles

1. **Free tier first** — All modules default to AWS Free Tier eligible services. Paid services are used only when the learning objective requires them and are explicitly flagged.
2. **Tag everything** — Every resource is tagged with `CostCenter`, `Environment`, `Module`, `Cloud`, `Creator`, and `DestroyAfter`. Use these in AWS Cost Explorer to track spend per lab.
3. **Clean up immediately** — Run `terraform destroy` and the module's `cleanup.ps1` after each session. AWS free tier expires after 12 months.
4. **Budget alerts** — Use AWS Budgets to set a $1 daily alert per lab before starting.

## Free Tier Limits (Relevant to These Labs)

| Service | Free Tier Limit | Applies to Modules |
|---------|----------------|-------------------|
| EC2 | 750 hours/month t2.micro or t3.micro | 01, 02, 06 |
| VPC | No charge for VPCs, subnets, route tables | All modules |
| Security Groups / NACLs | No charge | All modules |
| NAT Gateway | **Not free** — $0.045/hour | 01, 02 (required for private instances) |
| Client VPN | First 1,000 hours free | 02 |
| GuardDuty | 30-day free trial | 03, 05 |
| Security Hub | 30-day free trial | 05 |
| Macie | 30-day free trial | 07 |

## Module 01 Cost Breakdown

| Resource | Free Tier? | Quantity | Daily Cost | Notes |
|----------|-----------|----------|------------|-------|
| VPC | ✅ Yes | 1 | $0.00 | |
| Subnets (public, private-a, private-b) | ✅ Yes | 3 | $0.00 | |
| Security Groups | ✅ Yes | 4 | $0.00 | |
| NACLs | ✅ Yes | 2 | $0.00 | |
| Internet Gateway | ✅ Yes | 1 | $0.00 | |
| NAT Gateway | ❌ No | 1 | ~$1.08 | Only paid resource. **Use only during active lab sessions.** |
| EC2 t2.micro bastion | ✅ Yes | 1 | $0.00 | Within free tier hours |
| Route tables | ✅ Yes | 3 | $0.00 | |
| **Total** | | | **~$1.08/day** | |

> **Free tier warning**: NAT Gateway is not covered by the AWS free tier. At $0.045/hour, running for 2 hours costs $0.09. Always `terraform destroy` when done.

## Monthly Forecast (All 8 Modules)

| Module | Daily Cost (max) | Monthly (30d) |
|--------|-----------------|---------------|
| 01 — VPC Segmentation | $1.08 | $32.40 |
| 02 — Remote Access VPN | $1.20 | $36.00 |
| 03 — NGFW & IDS/IPS | $2.50 (trial) | $75.00 (trial then ~$10) |
| 04 — Zero Trust IAM | $0.00 | $0.00 |
| 05 — SIEM & UEBA | $0.00 (trial) | $0.00 |
| 06 — Incident Response | $1.08 | $32.40 |
| 07 — DLP & Endpoint | $0.00 (trial) | $0.00 |
| 08 — Compliance | $0.00 | $0.00 |
| **Estimated Total** | **~$5.86/day** | **~$175.80** |

> Cost is higher for AWS due to NAT Gateway charges. Minimize by destroying resources between sessions.

## Budget Alerts

Create an AWS Budget before running any lab:

```bash
aws budgets create-budget \
  --account-id ACCOUNT_ID \
  --budget file://shared/scripts/aws-budget-template.json
```

## Cleanup Best Practices

1. Run `terraform destroy -auto-approve` — destroys all tagged resources
2. Run the module's `cleanup.ps1` — prints a summary and checks for orphaned resources
3. Verify in AWS Console: **Billing and Cost Management → Cost Explorer**
4. Check for stray NAT Gateways (most common cause of unexpected charges)
