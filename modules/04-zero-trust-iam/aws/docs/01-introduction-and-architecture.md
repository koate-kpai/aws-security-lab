# SDCI Lab 04 — AWS: Introduction & Architecture

## Objective

Implement Zero Trust principles on AWS using IAM Roles, Permission Boundaries, and SSM Session Manager — mapping directly to the **SDCI 300-745 exam objective 4.0**.

## Zero Trust Principles Applied

### 1. Never Trust, Always Verify

The EC2 instance's Security Group **allows no inbound traffic**. There is no SSH rule, no HTTP rule — nothing. The only way to access the instance is through AWS SSM Session Manager, which authenticates the user via IAM and authorizes the session before connecting.

### 2. Least Privilege

The IAM Role attached to the EC2 instance has a **custom policy** with only two actions:
- `s3:GetObject` — download objects
- `s3:ListBucket` — list bucket contents

If the instance is compromised, the attacker cannot create, delete, or modify any S3 objects.

### 3. Permission Boundary

A **permission boundary** is applied to the role, capping the maximum permissions the role can ever have. Even if someone later attaches additional policies to the role, the boundary prevents escalation beyond `ec2:Describe*`, `ssm:*`, and `s3:Get*/List*`.

### 4. Workload Identity

Instead of static access keys, the **IAM Role is assumed by the EC2 instance** via an Instance Profile. The instance retrieves temporary credentials from the instance metadata service — no keys to store or rotate.

## Architecture

```
                          ┌──────────────────────────────────┐
                          │          AWS Account             │
                          │                                  │
                          │   Developer's Machine            │
                          │   aws ssm start-session          │
                          │          │                       │
                          │          ▼                       │
                          │   AWS SSM Session Manager        │
                          │   (authenticates via IAM,        │
                          │    authorizes session)           │
                          │          │                       │
                          │          ▼                       │
                          │   ┌──────────────────┐          │
                          │   │  Public Subnet   │          │
                          │   │  10.0.1.0/24     │          │
                          │   │  SG: Deny all    │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ t2.micro EC2  │ │          │
                          │   │ │ IAM Profile   │ │          │
                          │   │ └──────┬───────┘ │          │
                          │   └────────┼─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │  S3 Bucket       │          │
                          │   │  (read-only by   │          │
                          │   │   custom policy) │          │
                          │   └──────────────────┘          │
                          │                                  │
                          │   ┌──────────────────┐          │
                          │   │ Permission       │          │
                          │   │ Boundary         │          │
                          │   └──────────────────┘          │
                          │   (caps all policies)            │
                          └──────────────────────────────────┘
```

## Key IAM Resources

| Resource | Purpose |
|----------|---------|
| `aws_iam_role` | Workload identity for EC2 |
| `aws_iam_policy` (main) | Least-privilege S3 read-only policy |
| `aws_iam_policy` (boundary) | Permission boundary capping max permissions |
| `aws_iam_role_policy_attachment` | Attaches policies to role |
| `aws_iam_instance_profile` | Wraps role for EC2 attachment |

## Security Controls Checklist

| Control | Status | Notes |
|---------|--------|-------|
| No SSH inbound | ✅ | SG has no ingress rules at all |
| SSM Session Manager only | ✅ | SSM Agent on Amazon Linux 2 |
| Custom least-privilege policy | ✅ | 2 S3 read-only actions |
| Permission boundary | ✅ | Blocks permission escalation |
| Workload identity (no keys) | ✅ | Instance profile + metadata credentials |

## References

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM Permission Boundaries](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- [AWS SSM Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html)
- [Instance Metadata Service](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html)
