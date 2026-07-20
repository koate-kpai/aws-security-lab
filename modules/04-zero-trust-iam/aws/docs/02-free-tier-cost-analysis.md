# SDCI Lab 04 — AWS: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VPC + Subnet | Free | $0.00 | Always free |
| Internet Gateway | Free | $0.00 | Always free |
| Security Group | Free | $0.00 | Always free |
| EC2 t2.micro | $0.0116/hr | $0.00 | 750 hrs/mo free (12 months) |
| EBS gp3 (8 GB) | $0.08/GB/mo | ~$0.00 | First 30 GB free |
| SSM Session Manager | $0.00 | $0.00 | Free — no charge for sessions |
| SSM Agent | Free | $0.00 | Pre-installed on Amazon Linux 2 |
| IAM Role | Free | $0.00 | Always free |
| IAM Policy | Free | $0.00 | Always free |
| Permission Boundary | Free | $0.00 | Always free |
| S3 Standard bucket | $0.023/GB/mo | ~$0.00 | 5 GB free (12 months) |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier available | **$0.00** | $0.00 |
| **Worst case** — No free tier | **~$0.28** | ~$8.40 |

This is the **cheapest lab in the course** — everything is IAM/SSM, which are free services. The only cost driver is the EC2 instance, which is free tier eligible.

## Cost Optimization Tips

1. **SSM is free** — No per-session charges for Session Manager
2. **No VPC Endpoints needed** — SSM Agent can reach AWS endpoints over the internet; the public IP exists but has no open ports
3. **Permission boundaries** don't add cost but add significant security value
4. **Destroy when done** — even free tier has a 750 hr/mo limit

## FinOps Tags

All resources deployed with:

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Environment` | `Training` |
| `Module` | `04-zero-trust-iam` |
| `Cloud` | `aws` |
| `Creator` | `<your-email>` |
| `DestroyAfter` | `<YYYY-MM-DD>` |
