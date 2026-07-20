# Module 01: VPC Segmentation — Introduction & Architecture (AWS)

## What You'll Learn

This module aligns to the **Design Case Study Activity 1** from the Cisco SDCI 300-745 training — migrating a flat Layer 2 network to a layered, segmented design. You will:

1. Understand how the Cisco three-tier model maps to AWS VPC and subnets
2. Deploy a VPC with public (Access) and private (Distribution/Core) subnets
3. Enforce Security Group and NACL rules that simulate ACLs and micro-segmentation
4. Configure NAT Gateway for private instance egress
5. Verify lateral movement prevention between tiers

## Cisco → AWS Mapping

| Cisco Layer | AWS Resource | Purpose |
|-------------|-------------|---------|
| Access Layer (end-user ports) | Public subnet (10.0.1.0/24) + Internet Gateway | Bastion host and user-facing services. Public subnet has a route to the IGW. |
| Distribution Layer (routing, ACLs) | Private subnet A (10.0.2.0/24) + NACL + Security Groups | Policy enforcement boundary. Security Groups restrict inter-instance communication; NACLs enforce subnet-level isolation. |
| Core Layer (backbone) | Private subnet B (10.0.3.0/24) + NAT Gateway | Backend services. Outbound internet via NAT Gateway. Tightly controlled inbound from distribution only. |
| VLANs / micro-segmentation | Security Groups with source_sg references | Instance-level firewall rules. An SG assigned to the core subnet only allows traffic from the distribution SG. |

## Key AWS-Specific Design Decisions

1. **NACLs are stateless** — unlike GCP firewall rules and AWS Security Groups, NACLs require separate inbound AND outbound rules for return traffic. This makes them behave more like traditional Cisco ACLs, which is why we use them for the Distribution layer simulation.

2. **Security Groups are allow-only** — you cannot write a "deny" rule in a Security Group. To block access-tier→core traffic, we simply don't add an allow rule. The NACL provides the explicit deny boundary at the subnet level.

3. **NAT Gateway is per-AZ and expensive** — at $0.045/hour ($1.08/day), it's the only non-free resource. We provide the `enable_nat` toggle so learners can skip it if they don't need internet from private instances.

## Traffic Flow Diagram

```
                         Internet
                            │
                    [Internet Gateway]
                            │
                    ┌───────┴───────┐
                    │  Public Subnet│  ← Access Layer
                    │  10.0.1.0/24  │     Bastion host
                    │  (bastion)    │
                    └───────┬───────┘
                            │
                ┌───────────┴───────────┐
                │    Private Subnet A   │  ← Distribution Layer
                │    10.0.2.0/24       │     SG + NACL enforcement
                │    (policy boundary) │
                └───────────┬───────────┘
                            │
                ┌───────────┴───────────┐
                │    Private Subnet B   │  ← Core Layer
                │    10.0.3.0/24       │     Backend services
                │    (NAT Gateway)     │     ───→ Internet via NAT
                └───────────────────────┘
```
