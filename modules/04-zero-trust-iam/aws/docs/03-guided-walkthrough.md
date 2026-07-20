# SDCI Lab 04 — AWS: Guided Walkthrough

## Prerequisites

- AWS CLI installed and configured (`aws configure`)
- Session Manager plugin installed: `https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html`
- Terraform ≥ 1.6
- IAM permissions to create roles, policies, EC2 instances, and S3 buckets

## Step 1 — Deploy Infrastructure

```powershell
cd modules\04-zero-trust-iam\aws\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

**Expected output**: `Apply complete! Resources: <N> added.`

## Step 2 — Verify Zero Trust: No SSH Access

Get the instance's public IP from the EC2 console or Terraform state:

```powershell
$ip = (aws ec2 describe-instances --instance-ids (terraform output -raw instance_id) --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
```

Try to SSH (this should fail):

```bash
ssh ec2-user@$ip
# Expected: Connection timed out — no SSH port open in SG
```

## Step 3 — Access the EC2 via SSM Session Manager (Zero Trust)

```bash
$instanceId = terraform output -raw instance_id
aws ssm start-session --target $instanceId
```

**What happens behind the scenes:**
1. The CLI authenticates you via AWS IAM credentials
2. SSM checks you have `ssm:StartSession` permission
3. SSM Agent on the instance (pre-installed on Amazon Linux 2) opens a secure WebSocket
4. You get a shell — no SSH keys, no public ports, no bastion

## Step 4 — Verify Least-Privilege IAM

Once inside the SSM session, test what the IAM role can and cannot do:

```bash
# What the role CAN do — list bucket objects
aws s3 ls s3://sdci-04-aws-bucket-<account-id>/

# What the role CAN do — describe EC2 instances
aws ec2 describe-instances --region us-east-1

# What the role CANNOT do — upload to S3 (should fail)
echo "test" | aws s3 cp - s3://sdci-04-aws-bucket-<account-id>/test.txt
# Expected: AccessDenied — the policy doesn't include s3:PutObject

# What the role CANNOT do — delete the bucket
aws s3 rb s3://sdci-04-aws-bucket-<account-id>/
# Expected: AccessDenied
```

## Step 5 — Verify Permission Boundary

The permission boundary caps the role at `ec2:Describe*`, `ssm:*`, and `s3:Get*/List*`. Try to attach a broader policy:

```bash
# From your local machine (not SSM session)
aws iam attach-role-policy --role-name sdci-04-aws-role --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
# Expected: AccessDenied — the boundary prevents escalation beyond allowed actions
```

## Step 6 — Examine IAM Configuration

```bash
# View the role
aws iam get-role --role-name sdci-04-aws-role

# View the permission boundary
aws iam get-policy --policy-arn $(terraform output -raw boundary_arn)

# View the least-privilege policy
aws iam get-policy --policy-arn $(terraform output -raw policy_arn)
```

## Step 7 — Verify Instance Metadata

From within the SSM session, check the temporary credentials:

```bash
# The instance gets credentials from the metadata service
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/iam/security-credentials/
# Expected output: the role name
```

## Step 8 — Cleanup

```powershell
cd modules\04-zero-trust-iam\aws
.\cleanup.ps1
```

Verify in AWS Console: all resources destroyed.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `aws ssm start-session` fails | SSM Plugin not installed; see [AWS docs](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) |
| `TargetNotConnected` in SSM | SSM Agent not running; wait 2-3 mins after instance launch |
| `AccessDenied` on S3 list | IAM policy not attached; check `aws iam list-attached-role-policies` |
| Permission boundary not enforced | Boundary only restricts *maximum* permissions; check it's attached to the role |
| `ssh: connect to host` timeout | Correct! This is expected — no SSH ports open |
