# AWS Security Lab — Architecture

## Design Philosophy

These labs translate enterprise network security concepts from Cisco SDCI 300-745 into idiomatic AWS implementations. AWS's native VPC constructs — Subnets, Security Groups, NACLs, and Route Tables — map naturally to the Access/Distribution/Core layer model, but with important AWS-specific adaptations.

## Cross-Module Architecture

```
[User Devices] ──> [Public Subnet] ──> [NACL/SG Inspection] ──> [Private Subnets] ──> [NAT Gateway] ──> [Internet]
                        │                        │                       │
                        │     [GuardDuty/Network Firewall]               │
                        └──────────┴─────────────────────────────────────┘
                                              │
                                     [Security Hub]
                                              │
                                     [CloudWatch / Detective]
```

## Module 01: VPC Segmentation Architecture

### Mapping: Cisco 3-Tier → AWS

| Cisco Layer | AWS Resource | Purpose |
|-------------|-------------|---------|
| Access Layer | Public subnet (10.0.1.0/24) + Internet Gateway | End-user device connectivity, bastion host placement |
| Distribution Layer | Private subnet (10.0.2.0/24) + NACL | Policy enforcement boundary, inter-zone ACLs |
| Core Layer | Private core subnet (10.0.3.0/24) + NAT Gateway | Backend services, outbound internet via NAT |
| Micro-segmentation | Security Groups (instance-level) + prefix lists | Workload isolation down to individual instances |

### Traffic Flow Logic

1. **User-to-internal**: Bastion in public subnet SSHs into private instances
2. **Zone isolation**: NACL rules at the subnet boundary block cross-subnet traffic by default
3. **Internet egress**: Private instances route through the NAT Gateway
4. **Lateral movement prevention**: Security Groups with self-referencing rules restrict inter-instance traffic within the same subnet

### Key Decision: Public vs Private Subnets

Unlike GCP's flat subnet model, AWS enforces routing via Internet Gateway and NAT Gateway placement. We use this to our advantage — the Distribution layer naturally maps to the private subnet boundary where NACLs enforce zone-level policies, and Security Groups provide the micro-segmentation equivalent of firewall tags.

## Tagging Standards

Every resource in every module carries these mandatory tags:

| Tag Key | Value | Purpose |
|---------|-------|---------|
| `CostCenter` | `SDCI-Lab` | Group all lab costs in billing exports |
| `Environment` | `Training` | Distinguish lab from production |
| `Module` | e.g. `01-vpc-segmentation` | Per-module cost tracking |
| `Cloud` | `aws` | Cross-cloud cost comparison |
| `Creator` | (user input) | Who deployed this |
| `DestroyAfter` | `2026-08-20` | Safety net date |

## State Management

Labs use **local Terraform state** by design. Rationale:
- No shared S3 backend required for personal accounts
- `terraform destroy` reliably cleans up
- Simple to reset between training sessions

> For production deployments, migrate to an S3 backend with DynamoDB locking. See `shared/templates/`.
