# Module 01: VPC Segmentation — Guided Walkthrough (AWS)

**Estimated time**: 45 minutes  
**Daily cost**: ~$0.09 (2-hour session with NAT Gateway)  
**Prerequisites**: AWS CLI, Terraform >= 1.6, SSH key pair

---

## Step 0: Before You Start

### Cost Warning

This lab uses a **NAT Gateway** which costs **$0.045/hour** and is **NOT free tier eligible**. A 2-hour session costs ~$0.09. **Destroy immediately after completion.**

### Generate SSH Key

```powershell
ssh-keygen -t ed25519 -f ~/.ssh/sdci-lab
$env:TF_VAR_bastion_public_key = Get-Content ~/.ssh/sdci-lab.pub
$env:TF_VAR_creator = "your.email@example.com"
$env:TF_VAR_region = "us-east-1"
```

### Create a Budget Alert (Recommended)

```bash
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget-name "SDCI-Lab-Budget" \
  --budget-limit Amount=10,Unit=USD \
  --time-unit MONTHLY \
  --notification-threshold 80
```

---

## Step 1: Review the Architecture

Read `01-introduction-and-architecture.md`. Key points:

- **Public subnet** = Access Layer (bastion host)
- **Private subnet A** = Distribution Layer (policy boundary via SGs + NACLs)
- **Private subnet B** = Core Layer (backend, NAT egress)
- **Security Groups** = instance-level firewall (allow-only, stateful)
- **NACLs** = subnet-level firewall (allow+deny, stateless — more like Cisco ACLs)

---

## Step 2: Review Cost Estimate

```powershell
cd terraform
terraform init
terraform plan
```

Look for the **Cost Estimate** table:

```
╔══════════════════════════════════════════════════════════════╗
║  COST ESTIMATE — SDCI Lab 01: VPC Segmentation (AWS)       ║
╠══════════════════════════════════════════════════════════════╣
║ NAT Gateway                     1     $1.08       No  ***   ║
║ t2.micro bastion                1     $0.00       Yes*      ║
║ ──────────────────────────────────────────────────────────── ║
║  TOTAL                          -     $1.08                 ║
╚══════════════════════════════════════════════════════════════╝
```

If you plan to run this for 2 hours, your actual cost is ~$0.09.

---

## Step 3: Deploy

```powershell
terraform apply -auto-approve
```

Expected output: 15+ resources created.

---

## Step 4: Verify Segmentation

### Get Bastion IP

```powershell
$bastionIp = terraform output -raw bastion_public_ip
```

### SSH into Bastion

```powershell
ssh -i ~/.ssh/sdci-lab ubuntu@$bastionIp
```

### Deploy Test Instance in Core Subnet

From the bastion:

```bash
# Install AWS CLI
sudo apt-get update && sudo apt-get install -y awscli

# Get the core subnet and SG IDs
aws ec2 describe-subnets --filters "Name=tag:Tier,Values=core" --query "Subnets[0].SubnetId" --output text

# Launch test instance (you'll need the subnet and SG IDs)
```

### Test Lateral Movement

```bash
# From bastion → core instance (should SUCCEED — SG allows bastion SSH)
ssh ubuntu@CORE_INSTANCE_IP

# From a distribution-tier instance → core instance
# (should FAIL — NACL blocks non-public inbound by default)
```

---

## Step 5: Clean Up

```powershell
terraform destroy -auto-approve
.\cleanup.ps1 -AutoApprove
```

### Verify Cleanup

```bash
# Check for remaining NAT Gateways
aws ec2 describe-nat-gateways --filter Name=state,Values=pending,available

# Check for remaining lab resources
aws resourcegroupstaggingapi get-resources --tag-filters Key=CostCenter,Values=SDCI-Lab
```
