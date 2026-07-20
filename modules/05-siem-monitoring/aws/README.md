# SDCI Lab 05 — SIEM, Monitoring & UEBA (AWS)

SIEM and monitoring lab for the Cisco SDCI 300-745 exam using AWS CloudWatch, VPC Flow Logs, and Security Hub.

## Architecture

```
Traffic → VPC Flow Logs → CloudWatch Logs → Metric Filter → Alarm → SNS
                                                              ↓
                                                      Security Hub
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Network Monitoring | VPC Flow Logs to CloudWatch |
| Centralized Logging | CloudWatch Logs with 7-day retention |
| Metric Extraction | CloudWatch Metric Filter on SSH attempts |
| Alerting | CloudWatch Alarm → SNS notification |
| Security Posture | AWS Security Hub (findings dashboard) |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VPC/Flow Logs/CW Logs | ~$0.02 |
| EC2 t2.micro | $0.00 (free tier) |
| CloudWatch Metrics/Alarms | $0.00 (free tier) |
| Security Hub | $0.00 (30-day trial) |
| **Total** | **~$0.02/day** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Verify Monitoring Pipeline

```bash
# 1. Generate SSH traffic (from any machine)
ssh fakeuser@<PUBLIC_IP>

# 2. Check CloudWatch Logs for flow log entries
# Console: CloudWatch → Log Groups → sdci-05-aws-flow-logs

# 3. Check the metric
# CloudWatch → Metrics → SDCI/Lab05 → SSHAttempts

# 4. Check the alarm
# CloudWatch → Alarms → sdci-05-aws-high-ssh
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
