# AWS Security Lab

Hands-on security training labs for Amazon Web Services, aligned to **Cisco SDCI 300-745** exam objectives.

## Alignment to Cisco SDCI 300-745

This repo maps the following 300-745 domains into practical AWS implementations:

| 300-745 Domain | AWS Lab Module | Key AWS Services |
|---------------|----------------|------------------|
| Network segmentation & layered architecture | 01 - VPC Segmentation | VPC, subnets, Security Groups, NACLs |
| Remote access & VPN connectivity | 02 - Remote Access VPN | Client VPN, Site-to-Site VPN, Transit Gateway |
| NGFW, IDS/IPS, zone-based firewalls | 03 - NGFW & IDS/IPS | Network Firewall, GuardDuty, WAF |
| Zero Trust & RBAC | 04 - Zero Trust IAM | IAM, SCP, Verified Permissions, Cognito |
| SIEM, monitoring, UEBA | 05 - SIEM & UEBA | Security Hub, Detective, CloudWatch |
| Incident response & containment | 06 - Incident Response | VPC Flow Logs, Security Groups, EC2 quarantine |
| DLP & endpoint security | 07 - DLP & Endpoint | Macie, GuardDuty, Systems Manager |
| Compliance & auditing | 08 - Compliance | Artifact, Config, Audit Manager |

## Prerequisites

- AWS account with billing enabled (free tier eligible)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- PowerShell 5.1+ (for cleanup scripts)

## Quick Start

```powershell
# Clone the repo
git clone https://github.com/koate-kpai/aws-security-lab.git
cd aws-security-lab

# Navigate to a module
cd modules/01-vpc-segmentation/aws/terraform

# Review costs before deploying
terraform init
terraform plan

# Deploy
terraform apply -auto-approve

# Verify segmentation
aws ec2 describe-instances

# Clean up
terraform destroy -auto-approve
```

## Repository Structure

```
aws-security-lab/
├── README.md
├── ARCHITECTURE.md
├── COST-GUIDE.md
├── sprints/
│   └── 01-foundation-segmentation.md
├── modules/
│   └── 01-vpc-segmentation/
│       └── aws/
│           ├── terraform/           # IaC code
│           ├── docs/                # Architecture, cost, walkthrough
│           └── cleanup.ps1          # Module-specific cleanup
└── shared/
    ├── scripts/                    # Common utilities
    └── templates/                  # Module scaffolding
```

## Cost Management

All modules are designed for **free tier first**. Where paid resources are unavoidable, they are explicitly flagged with cost warnings. See [COST-GUIDE.md](./COST-GUIDE.md) for details.

> **Important**: AWS free tier expires 12 months after account creation. Some labs use services outside the free tier at minimal cost (~$0.04/day). Always run `terraform destroy` after completing a lab.

## License

For educational and training purposes only.
