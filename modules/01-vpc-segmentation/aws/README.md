# SDCI Lab 01 — VPC Segmentation (AWS)

**Cisco SDCI 300-745 Domain**: Network segmentation & layered architecture

## Overview

This lab translates the **flat-to-layered network migration** case study into AWS. You'll provision a three-tier VPC with public (Access) and private (Distribution/Core) subnets, enforce zone-based security groups and NACLs, and verify lateral movement prevention.

## Cost Warning

AWS NAT Gateway costs ~$1.08/day and is **NOT free tier eligible**. The daily budget cap of $1.00 is exceeded if left running. This lab is designed for **single-session use** — deploy, verify, destroy within 2 hours (~$0.09).

## Files

| File | Purpose |
|------|---------|
| `terraform/` | All Terraform IaC |
| `docs/01-introduction-and-architecture.md` | Architecture deep dive |
| `docs/02-free-tier-cost-analysis.md` | Cost breakdown |
| `docs/03-guided-walkthrough.md` | Step-by-step instructions |
| `cleanup.ps1` | Resource destruction |

## Quick Commands

```powershell
cd terraform
terraform init
terraform plan     # Review + cost estimate
terraform apply    # Deploy
terraform destroy  # Clean up
```
