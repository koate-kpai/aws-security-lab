# SDCI Lab 05 — AWS: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VPC + Subnet + IGW | Free | $0.00 | Always free |
| Security Group | Free | $0.00 | Always free |
| VPC Flow Logs | $0.50/GB ingested | ~$0.02 | Minimal |
| CloudWatch Logs | $0.50/GB ingested | $0.00 | 5 GB free |
| CloudWatch Metric Filter | Free | $0.00 | Free |
| CloudWatch Alarm | $0.10/alarm/mo | $0.00 | 10 alarms free |
| SNS Topic | $0.50/1M publishes | $0.00 | 1M publishes free |
| EC2 t2.micro | $0.0116/hr | $0.00 | 750 hrs/mo free |
| Security Hub | $0.00 | $0.00 | 30-day free trial |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — All free tier/trial | **~$0.00** | ~$0.00 |
| **Worst case** — No free tier | **~$0.30** | ~$9.00 |

## Cost Optimization

- Security Hub costs ~$0.0015 per finding per day after trial — disable it when not in use
- VPC Flow Logs are the main cost driver at scale ($0.50/GB)
- CloudWatch Logs Insights queries cost $0.005/GB scanned

## FinOps Tags

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Module` | `05-siem-monitoring` |
| `Cloud` | `aws` |
| `Creator` | `<your-email>` |
