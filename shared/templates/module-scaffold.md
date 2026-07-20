# AWS Module Scaffold Template

## Directory Structure

```
modules/{NN}-{module-name}/
└── aws/
    ├── terraform/
    │   ├── versions.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── variables_extra.tf
    │   ├── locals.tf
    │   ├── vpc.tf
    │   ├── security_groups.tf
    │   ├── nacl.tf
    │   ├── routing.tf
    │   ├── bastion.tf
    │   ├── outputs.tf
    │   └── cost-estimate.tf
    ├── docs/
    │   ├── 01-introduction-and-architecture.md
    │   ├── 02-free-tier-cost-analysis.md
    │   └── 03-guided-walkthrough.md
    ├── cleanup.ps1
    └── README.md
```

## Terraform Design Rules

1. **Unique per-module SG and NACL naming** via `locals.name_prefix` — all security resources prefix with `sdci-{NN}-aws-`.
2. **SSH key is required** — use `variables_extra.tf` to enforce `bastion_public_key`.
3. **NAT Gateway toggle** — always include an `enable_nat` variable. Default `true` but document the cost.
4. **Security Groups over NACLs for granularity** — SGs are stateful and instance-level. NACLs are stateless and subnet-level. Use both for defense-in-depth.
5. **Cost estimate** — always include a `cost-estimate.tf` that prints during plan.
6. **Tag enforcement** — every resource uses `tags = merge(local.tags, { Name = local.xxx })`.
