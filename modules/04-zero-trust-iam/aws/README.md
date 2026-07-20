# SDCI Lab 04 — Zero Trust & Identity Access Management (AWS)

Zero Trust IAM lab for the Cisco SDCI 300-745 exam using AWS IAM, SSM Session Manager, and Permission Boundaries.

## Architecture

```
Developer → AWS SSM Session Manager (Zero Trust) → EC2 (no SSH open)
                                                        ↓
                                              IAM Role + Instance Profile
                                                        ↓
                                              S3 Bucket (least-privilege read)
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Zero Trust Network Access | SSM Session Manager — no SSH ports open |
| Workload Identity | IAM Role + Instance Profile on EC2 |
| Least-Privilege IAM | Custom policy: only `s3:GetObject` + `s3:ListBucket` |
| Permission Boundary | Caps maximum permissions regardless of attached policies |
| Policy-as-Code | All IAM defined in Terraform |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VPC/Subnet/IGW | $0.00 |
| EC2 t2.micro | $0.00 (free tier) |
| SSM Session Manager | $0.00 |
| IAM Role/Policies | $0.00 |
| S3 Bucket | ~$0.00 |
| **Total** | **~$0.00/day** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Access the EC2 (via SSM — no SSH)

```bash
aws ssm start-session --target <instance-id>
```

## Verify Zero Trust

```bash
# Try SSH directly (should fail — port 22 not open)
ssh ec2-user@<public-ip>
# Expected: Connection timed out

# From within the SSM session — list bucket objects
aws s3 ls s3://sdci-04-aws-bucket-<account-id>/

# Try to upload (should fail — least privilege)
echo "test" | aws s3 cp - s3://sdci-04-aws-bucket-<account-id>/test.txt
# Expected: AccessDenied
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
