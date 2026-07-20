# SDCI Lab 03 — AWS: Introduction & Architecture

## Objective

Build a multi-layered security defence on AWS demonstrating NGFW (WAF), zone-based firewalls (SG + NACL), and threat detection (GuardDuty) — mapping directly to the **SDCI 300-745 exam objective 3.0**.

## Three-Layer Security Architecture

### Layer 1 — AWS WAF (Application Layer Firewall / NGFW)

AWS WAF is a web application firewall that monitors and controls HTTP/S traffic to your ALB.

- **SQLi rule** — Inspects request body for SQL injection patterns (`' OR 1=1`, `UNION SELECT`, etc.)
- **XSS rule** — Blocks cross-site scripting payloads in URL, body, or headers
- **Rate limit rule** — Drops requests from any IP exceeding 2000 requests in 5 minutes

### Layer 2 — Security Groups + NACLs (Zone-Based Firewall)

| Zone | Resource | Inbound | Outbound | Philosophy |
|------|----------|---------|----------|------------|
| **Web** | Security Group | HTTP from ALB only, SSH from anywhere | All traffic | _Default deny — only allow web traffic_ |
| **App** | Security Group | HTTP from Web SG only | All traffic | _Micro-segmentation — App only trusts Web_ |
| **Web** | NACL | HTTP from 0.0.0.0/0 | All traffic | _Stateless — distribution ACL_ |
| **App** | NACL | HTTP from 10.0.1.0/24, ephemeral ports | All traffic | _Stateless — blocks non-web subnet_ |

### Layer 3 — GuardDuty (Threat Detection / IDS)

GuardDuty continuously monitors VPC Flow Logs, DNS query logs, and CloudTrail management events for suspicious activity:

- Unauthorized port probes
- Communication with known malicious IPs
- Unusual traffic patterns or data exfiltration

## Network Topology

```
                          ┌──────────────────────────────┐
                          │         AWS Account           │
                          │                              │
                          │   ┌──── ALB ────┐             │
                          │   │   (Public)   │            │
                          │   └──────┬───────┘            │
                          │          │ HTTP/80             │
                          │          ▼                    │
                          │ ┌──────────────────┐         │
                          │ │   Web Subnet     │         │
                          │ │  10.0.1.0/24     │         │
                          │ │  ┌─────────────┐ │         │
                          │ │  │ Web SG       │ │         │
                          │ │  │ HTTP:ALB     │ │         │
                          │ │  │ SSH:0.0.0.0/0│ │         │
                          │ │  └─────────────┘ │         │
                          │ │  NACL: HTTP/80   │         │
                          │ └────────┬─────────┘         │
                          │          │ HTTP/80            │
                          │          ▼                    │
                          │ ┌──────────────────┐         │
                          │ │   App Subnet     │         │
                          │ │  10.0.2.0/24     │         │
                          │ │  ┌─────────────┐ │         │
                          │ │  │ App SG       │ │         │
                          │ │  │ HTTP:Web SG  │ │         │
                          │ │  └─────────────┘ │         │
                          │ │  NACL: 10.0.1.0/24│        │
                          │ └──────────────────┘         │
                          │                              │
                          │   GuardDuty Detector         │
                          │   (VPC Flow Logs +           │
                          │    CloudTrail)                │
                          └──────────────────────────────┘
```

## Key Takeaway

In enterprise environments (and the SDCI exam), security is never single-layer. Combining **WAF (L7) + firewalls (L3-4) + threat detection (IDS)** provides defense-in-depth:

- WAF stops application-level exploits
- SGs/NACLs enforce zone boundaries and micro-segmentation
- GuardDuty catches anything that slips past both

## References

- [AWS WAF Developer Guide](https://docs.aws.amazon.com/waf/latest/developerguide/)
- [AWS GuardDuty User Guide](https://docs.aws.amazon.com/guardduty/latest/ug/)
- [VPC Security — Security Groups vs NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)
