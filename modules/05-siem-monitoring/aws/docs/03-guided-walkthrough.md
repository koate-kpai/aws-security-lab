# SDCI Lab 05 — AWS: Guided Walkthrough

## Prerequisites

- AWS CLI installed and configured
- Terraform ≥ 1.6

## Step 1 — Deploy

```powershell
cd modules\05-siem-monitoring\aws\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — Generate Log Traffic

From any machine, attempt SSH to the EC2 instance:

```bash
ssh invalid@$(terraform output -raw instance_public_ip)
```

Repeat 10-15 times to trigger the alarm threshold.

## Step 3 — Examine VPC Flow Logs in CloudWatch

Navigate to **CloudWatch → Log Groups → sdci-05-aws-flow-logs**:

```
terraform output cloudwatch_logs_url
```

Use **CloudWatch Logs Insights** to query SSH traffic:

```
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter dstPort = 22
| sort @timestamp desc
| limit 50
```

## Step 4 — Examine the Metric

Navigate to **CloudWatch → Metrics → SDCI/Lab05 → SSHAttempts**.

- View the graphed metric
- Set the time range to the last 1 hour
- You should see spikes corresponding to your SSH attempts

## Step 5 — Check the Alarm

Navigate to **CloudWatch → Alarms → sdci-05-aws-high-ssh**.

- Status should show **ALARM** if you generated enough SSH attempts
- View the **History** tab for state transitions

## Step 6 — Explore Security Hub

Navigate to **Security Hub** from the AWS Console.

- View the **Summary** dashboard
- Check **Security standards** (CIS, PCI-DSS, AWS Foundational)
- View **Findings** — may take a few minutes to populate

## Step 7 — Cleanup

```powershell
cd modules\05-siem-monitoring\aws
.\cleanup.ps1
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No flow logs in CloudWatch | Wait 5-10 min; VPC Flow Logs are not real-time |
| Metric filter shows 0 | The pattern may need to match AWS flow log format exactly |
| Alarm not firing | Threshold is 10; generate more SSH attempts in quick succession |
| Security Hub not enabled | Requires AWS Organizations or manual enable; may take 24 hrs |
