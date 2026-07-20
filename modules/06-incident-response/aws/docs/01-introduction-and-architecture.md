# SDCI Lab 06 — AWS: Introduction & Architecture

## Objective

Implement incident response quarantine on AWS using Security Group swap and NACL isolation — mapping to **SDCI 300-745 objective 6.0**.

## Two Quarantine Mechanisms

### 1. Security Group Swap (Instance-Level)

Fastest quarantine: replace the instance's SG with a deny-all SG that has zero ingress and zero egress rules. Since SGs are stateful, existing connections are also dropped (no default allow egress).

### 2. NACL Isolation (Subnet-Level)

Apply a deny-all NACL to the subnet. NACLs are stateless and affect all instances in the subnet. Useful for isolating an entire compromised subnet.

## Architecture

```
Normal EC2 (SG: normal)       ─── SSH ✅
Quarantined EC2 (SG: deny)    ─── SSH ❌
Normal + NACL deny            ─── SSH ❌ (subnet-level)
```

## Quarantine Script

```powershell
.\scripts\quarantine.ps1 -InstanceId i-xxx -Action quarantine
```

## Automation

In production, the SG swap would be triggered by a Lambda function responding to a GuardDuty finding or Security Hub alert.

## References

- [Modify Instance Attribute](https://docs.aws.amazon.com/cli/latest/reference/ec2/modify-instance-attribute.html)
- [Security Groups vs NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html)
