# SDCI Lab 03 — AWS: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VPC + subnets | Free | $0.00 | Always free |
| Internet Gateway | Free | $0.00 | Always free |
| AWS WAF Web ACL | Per ACL + per rule | $0.00 | 5 ACLs free per account |
| AWS WAF rules (3 rules) | Per rule (first 1,000 free) | $0.00 | Included in 5 free ACLs |
| GuardDuty | Per GB of CloudTrail/Flow Logs | $0.00 | 30-day free trial |
| ALB | $0.0225/hr | ~$0.54 | — |
| EC2 t2.micro | $0.0116/hr | ~$0.28 | 750 hrs/mo free (12 months) |
| EBS gp3 (20 GB) | $0.08/GB/mo | ~$0.05 | First 30 GB free |
| VPC Flow Logs | $0.50/GB ingested | ~$0.02 | Minimal |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier + trial fully available | **~$0.56** | ~$16.80 |
| **Worst case** — No free tier/trial | **~$0.89** | ~$26.70 |

## Cost Optimization Tips

1. **Destroy after lab**: Always run `cleanup.ps1` after finishing — GuardDuty trial begins counting the moment you enable it
2. **GuardDuty trial**: Disable after testing by deleting the detector; 30-day trial is per-account, not per-detector
3. **ALB idle cost**: ALB costs $0.0225/hr whether traffic flows or not — destroy when idle
4. **NACL limits**: 20 rules per NACL by default — request a limit increase if needed for complex scenarios
5. **Free tier credits**: If you are a new AWS account, 750 hrs/mo of t2.micro + the WAF free tier means this lab costs **~$0.54/day for ALB only**

## FinOps Tags

All resources deployed with:

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Environment` | `Training` |
| `Module` | `03-ngfw-ids-ips` |
| `Cloud` | `aws` |
| `Creator` | `<your-email>` |
| `DestroyAfter` | `<YYYY-MM-DD>` |
