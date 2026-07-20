# SDCI Lab 05 — AWS: Introduction & Architecture

## Objective

Deploy a complete SIEM monitoring pipeline on AWS — VPC Flow Log ingestion into CloudWatch, metric filter extraction, CloudWatch alarm with SNS notification, and Security Hub — mapping directly to **SDCI 300-745 exam objective 5.0**.

## Monitoring Pipeline Architecture

### Ingestion Layer — VPC Flow Logs

VPC Flow Logs capture IP traffic metadata: source/destination IP, ports, protocol, packets, and action (ACCEPT/REJECT). Logs are published to CloudWatch Logs via an IAM role with `logs:PutLogEvents` permissions.

### Storage Layer — CloudWatch Logs

CloudWatch Logs stores log events with configurable retention (7 days in this lab). The log group `sdci-05-aws-flow-logs` collects all VPC flow log entries. Logs are queryable via the CloudWatch Logs Insights query language.

### Analysis Layer — CloudWatch Metric Filter

The metric filter `sdci-05-aws-ssh-attempts` parses each flow log entry and creates a metric called `SSHAttempts` in the `SDCI/Lab05` namespace when it matches the pattern for SSH traffic (destination port 22, protocol 6 = TCP).

### Alerting Layer — CloudWatch Alarm + SNS

The alarm `sdci-05-aws-high-ssh` fires when the sum of `SSHAttempts` exceeds 10 in a 5-minute period. When the alarm fires, it publishes to the SNS topic, which can send email/SMS/Slack notifications.

### Security Posture — Security Hub

AWS Security Hub aggregates findings from AWS services (GuardDuty, Inspector, etc.) and displays them on a single dashboard. It also runs continuous security checks against best-practice standards (CIS, PCI-DSS, AWS Foundational Security Best Practices).

## Architecture Diagram

```
                          ┌──────────────────────────────────┐
                          │          AWS Account             │
                          │                                  │
                          │   External SSH attempt           │
                          │   (synthetic traffic)            │
                          │          │                       │
                          │          ▼                       │
                          │   ┌──────────────────┐          │
                          │   │  Public Subnet   │          │
                          │   │  10.0.1.0/24     │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ t2.micro EC2 │ │          │
                          │   │ │ (SSH target) │ │          │
                          │   │ └──────┬───────┘ │          │
                          │   └────────┼─────────┘          │
                          │            │ VPC Flow Logs       │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ CloudWatch Logs   │          │
                          │   │ (flow log group)  │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ Metric Filter    │          │
                          │   │ (SSH attempts)   │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ CloudWatch Alarm │          │
                          │   │ (>10 SSH/5min)   │          │
                          │   └────────┬─────────┘          │
                          │            │ SNS                 │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ SNS Topic        │          │
                          │   │ (notifications)  │          │
                          │   └──────────────────┘          │
                          │                                  │
                          │   ┌──────────────────┐          │
                          │   │ Security Hub     │          │
                          │   │ (findings)       │          │
                          │   └──────────────────┘          │
                          └──────────────────────────────────┘
```

## SIEM Comparison: AWS CloudWatch vs Traditional SIEM

| Capability | Traditional SIEM | AWS CloudWatch + Security Hub |
|------------|-----------------|------------------------------|
| Log ingestion | Agents required | Agentless (VPC Flow, CloudTrail) |
| Storage | Self-managed | Managed, auto-scaled |
| Retention | Limited by hardware | Configurable (1 day - 10 years) |
| Alerting | Rule-based | Metric Filter + Alarm |
| Dashboard | Custom build | Security Hub + CloudWatch Dashboards |
| Cost | $1-5/GB/day | $0.50/GB ingested (flow logs) |

## References

- [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/)
- [CloudWatch Metric Filters](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/MetricFilters.html)
- [AWS Security Hub](https://docs.aws.amazon.com/securityhub/latest/userguide/)
