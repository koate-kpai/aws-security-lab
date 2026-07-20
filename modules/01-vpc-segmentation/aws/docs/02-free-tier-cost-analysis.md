# Module 01: VPC Segmentation — Cost Analysis (AWS)

## Cost Philosophy

This lab prioritizes free tier usage but is constrained by two AWS realities:

1. **NAT Gateway is never free** — $0.045/hour ($1.08/day)
2. **Free tier expires after 12 months** — t2.micro is only free for the first year

## Resource Cost Breakdown

| Resource | AWS Service | Free Tier? | Daily Cost | Monthly | Notes |
|----------|------------|-----------|------------|---------|-------|
| VPC | `aws_vpc` | ✅ Always free | $0.00 | $0.00 | |
| Subnets (3) | `aws_subnet` | ✅ Always free | $0.00 | $0.00 | |
| Security Groups (3) | `aws_security_group` | ✅ Always free | $0.00 | $0.00 | |
| NACLs (2) | `aws_network_acl` | ✅ Always free | $0.00 | $0.00 | |
| Internet Gateway | `aws_internet_gateway` | ✅ Always free | $0.00 | $0.00 | |
| Route Tables (2) | `aws_route_table` | ✅ Always free | $0.00 | $0.00 | |
| Elastic IP | `aws_eip` | ✅ Always free* | $0.00 | $0.00 | Free when associated with running NAT |
| NAT Gateway | `aws_nat_gateway` | ❌ **Not free** | **$1.08** | **$32.40** | $0.045/hr + data processing |
| t2.micro bastion | `aws_instance` | ⚠️ Limited free | $0.00 | $0.00 | 750 hrs/month free (first 12 months) |
| **Total** | | | **$1.08** | **$32.40** | |

*\*Elastic IP is free when attached to a running instance/NAT. Detached EIPs incur charges.*

## Budget Cap Compliance

The daily budget cap is **$1.00 per lab**. The NAT Gateway alone costs **$1.08/day** if left running 24 hours.

**Strategy to stay under cap**: Run the lab in a single 2-hour session ($0.09) and destroy immediately. The effective daily cost for a single session is $0.09 — well under $1.00.

## Cost Optimization Tips

1. **Skip the NAT Gateway**: Set `enable_nat = false` if your verification steps don't need internet from private instances. This saves the full $1.08/day.

2. **Skip the bastion**: Use AWS Systems Manager Session Manager instead. Set `enable_bastion = false`.

3. **Destroy immediately**: The NAT Gateway billing is per-second after the first hour. A 2-hour session costs ~$0.09.

4. **Check free tier usage**: Monitor at https://console.aws.amazon.com/billing/home#/freetier

5. **Use AWS Budgets**:

```bash
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://../../shared/scripts/aws-budget-template.json
```

## FinOps Tagging

Every resource carries these tags:

| Tag Key | Value | Use in Cost Explorer |
|---------|-------|---------------------|
| `CostCenter` | `SDCI-Lab` | Group all lab costs |
| `Environment` | `Training` | Filter from production |
| `Module` | `01-vpc-segmentation` | Per-module tracking |
| `Cloud` | `aws` | Cross-cloud comparison |
| `Creator` | your-email | Cost attribution |

Query in AWS Cost Explorer: `tag:CostCenter = SDCI-Lab AND tag:Module = 01-vpc-segmentation`
