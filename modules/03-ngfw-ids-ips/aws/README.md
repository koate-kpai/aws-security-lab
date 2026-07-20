# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (AWS)

Three-tier security lab for the Cisco SDCI 300-745 exam using AWS native services.

## Architecture

```
Internet → AWS WAF → ALB → Web Subnet → App Subnet
                                ↓
                         GuardDuty
```

## Services Used

| Layer | Service | AWS Offering |
|-------|---------|-------------|
| L7 WAF | AWS WAF | Web ACL blocking SQLi, XSS, rate limiting |
| L3-4 FW | Security Groups + NACLs | Stateful instance rules + stateless subnet ACLs |
| Threat Detection | GuardDuty | VPC Flow Log & CloudTrail analysis |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VPC/Subnets/SGs/NACLs | $0.00 |
| AWS WAF (free tier) | $0.00 |
| GuardDuty (30-day trial) | $0.00 |
| ALB | ~$0.54 |
| EC2 t2.micro | ~$0.35 |
| **Total** | **~$0.89/day worst case** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=your.email@example.com"
terraform apply -var="creator=your.email@example.com" -auto-approve
```

## Test WAF

```bash
# Normal request — allowed
curl -I http://<ALB_DNS>

# SQL injection — blocked (403)
curl -I "http://<ALB_DNS>/?id=1' OR '1'='1"

# XSS — blocked (403)
curl -I "http://<ALB_DNS>/?q=<script>alert(1)</script>"
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
