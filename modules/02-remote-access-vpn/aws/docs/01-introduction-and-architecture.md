# Module 02: Remote Access VPN — Architecture (AWS)

## Scenario

Remote employees need secure, encrypted access to internal applications from anywhere. This is the **Internet Edge** + **VPN** scenario from SDCI 300-745.

## AWS Solution: Client VPN

AWS Client VPN is a managed OpenVPN-based service. Users authenticate with certificates and connect to a VPN endpoint. Authorization rules control which networks each user can access.

### Architecture

```
┌──────────────────┐     OpenVPN      ┌──────────────────┐
│  Remote User     │◄══════════════►  │  AWS Cloud       │
│  (laptop)        │    UDP/443        │                  │
│  OpenVPN client  │                  │  ┌────────────┐  │
└──────────────────┘                  │  │Client VPN  │  │
                                      │  │Endpoint    │  │
                                      │  │(public sub)│  │
                                      │  └─────┬──────┘  │
                                      │        │         │
                                      │  ┌─────┴──────┐  │
                                      │  │Workload    │  │
                                      │  │(private    │  │
                                      │  │ subnet)    │  │
                                      │  └────────────┘  │
                                      └──────────────────┘
```

### Key Components

| Component | AWS Resource | Purpose |
|-----------|-------------|---------|
| Client VPN Endpoint | `aws_ec2_client_vpn_endpoint` | Managed VPN termination point |
| Server Certificate | `aws_acm_certificate` | VPN endpoint identity |
| Client Certificate | `tls_locally_signed_cert` | User authentication |
| Authorization Rule | `aws_ec2_client_vpn_authorization_rule` | Network access control |
| Security Group | `aws_security_group` | Instance-level firewall |

### SDCI 300-745 Connection

This demonstrates the **Internet Edge + VPN** combination: VPNs create encrypted tunnels across the public internet, and the Internet Edge is where those tunnels terminate.
