# Sprint 1 — Foundation & VPC Segmentation (AWS)

**Sprint Goal**: Establish the repository scaffold, shared modules, and implement Module 01 (VPC Segmentation) for AWS. Complete the architecture, Terraform IaC, documentation, and cleanup scripts.

## Epic: Foundation & Network Segmentation

| Story | Status | Deliverable |
|-------|--------|-------------|
| 1.1 Repo scaffold | ✅ Complete | README, ARCHITECTURE.md, COST-GUIDE.md, .gitignore |
| 1.2 Shared modules | ✅ Complete | `shared/scripts/cleanup.ps1`, `shared/templates/module-scaffold.md` |
| 1.3 AWS Terraform IaC | 📋 Planned | `terraform/*.tf` — VPC, subnets, SGs, NACLs, NAT Gateway, bastion |
| 1.4 AWS docs | 📋 Planned | Architecture guide, cost analysis, guided walkthrough |
| 1.5 Git repository | 📋 Planned | Initialize git, commit, push to `github.com/koate-kpai/aws-security-lab` |

## Key Decisions Made

1. **Three-tier mapping**: Access → public subnet + IGW, Distribution → private subnet + NACL, Core → private core subnet + NAT
2. **NAT Gateway**: Only paid resource (~$1.08/day if left running). Required for private instance egress. Flagged with cost warning. Users should destroy after each session.
3. **Local state**: Personal accounts don't have shared backends. Local state is simpler for training.
4. **No Transit Gateway**: Not free tier eligible. VPC peering used where needed.

## Cost Forecast for Sprint 1

| Resource | Daily Cost | Monthly (if left running) |
|----------|-----------|--------------------------|
| NAT Gateway | $1.08 | $32.40 |
| EC2 t2.micro bastion (free tier) | $0.00 | $0.00 |
| VPC/subnets/SGs/NACLs (free) | $0.00 | $0.00 |
| **Total** | **$1.08** | **$32.40** |

> **WARNING**: AWS free tier expires after 12 months. NAT Gateway is never free. Destroy immediately after each lab session.

## Definition of Done

- [x] Repository scaffold with README, ARCHITECTURE, COST-GUIDE
- [x] Shared cleanup script and module template
- [ ] `terraform init && terraform plan` succeeds without errors
- [ ] `terraform apply` creates VPC, 3 subnets, SGs, NACLs, IGW, NAT Gateway
- [ ] Verification steps in walkthrough produce expected results
- [ ] `terraform destroy` cleans up all resources cleanly
- [ ] Git repo initialized and pushed

## Next Steps (Sprint 2)

- Start Module 02 (Remote Access VPN) for AWS
- Mirror remaining GCP modules
