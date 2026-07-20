# SDCI Lab 03 — AWS: Guided Walkthrough

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Terraform ≥ 1.6
- An AWS account with permissions to create VPCs, WAF, ALB, EC2, GuardDuty

## Step 1 — Deploy Infrastructure

```powershell
cd modules\03-ngfw-ids-ips\aws\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

**Expected output**: `Apply complete! Resources: <N> added.` + ALB DNS name in outputs.

## Step 2 — Verify WAF Is Active

Grab the ALB DNS from `terraform output`:

```powershell
$dns = terraform output -raw alb_dns_name
```

**Test 1 — Normal request** (should return 200):

```bash
curl -I http://$dns
```

**Test 2 — SQL injection attempt** (should return 403 Forbidden):

```bash
curl -I "http://$dns/?id=1' OR '1'='1"
```

**Test 3 — XSS attempt** (should return 403):

```bash
curl -I "http://$dns/?q=<script>alert('xss')</script>"
```

## Step 3 — Verify Zone-Based Firewall (SG + NACL)

Create a test instance in the **App** subnet and try to reach the web instance directly:

```powershell
# SSH into the web instance (use SSM Session Manager or direct SSH)
# From within the VPC, verify Web → App connectivity:
curl -I http://<app-instance-private-ip>

# Verify App cannot reach the Internet directly (NACL enforces this)
curl -I http://google.com   # Should timeout
```

## Step 4 — Explore GuardDuty

Navigate to **GuardDuty → Findings** in the AWS Console.

- Observe the finding types generated
- GuardDuty will log port scans, suspicious DNS queries, and unusual HTTP patterns
- Note: Findings may take 5–10 minutes to appear after first deployment

_Generate a finding_ by trying an SSH brute force from an external IP (or simply note the absence of findings as a baseline).

## Step 5 — Examine WAF Metrics

Navigate to **AWS WAF → Web ACLs → `sdci-03-aws-waf` → Monitoring**:

- View the **BlockedRequests** metric
- See counts of SQL injection and XSS blocks
- Verify no valid traffic was inadvertently blocked
- Check **Sampled Requests** for a detailed view of matching requests

## Step 6 — Cleanup

```powershell
cd modules\03-ngfw-ids-ips\aws
.\cleanup.ps1
```

Verify in AWS Console: all resources destroyed.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `curl` gets `curl: (7) Failed to connect` | ALB provisioning takes 2-3 mins; wait and retry |
| WAF returns 200 on SQLi test | Verify WAF is associated with ALB; check `aws_wafv2_web_acl_association` |
| GuardDuty shows no findings | Detector takes time to initialise; generate VPC Flow Logs by pinging the ALB |
| `terraform apply` fails on GuardDuty | Detector already exists; use `terraform import` or remove manually |
