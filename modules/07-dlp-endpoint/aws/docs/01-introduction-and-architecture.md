# SDCI Lab 07 — AWS: Introduction & Architecture

## Objective

Deploy a DLP pipeline using Amazon Macie to discover and classify sensitive data in S3 — mapping to **SDCI 300-745 objective 7.0**.

## Macie Pipeline

### 1. Data Storage — S3 Buckets

Two S3 buckets:
- **Sensitive bucket** — contains `customers.csv` with fake PII (credit cards, SSNs, emails)
- **Clean bucket** — contains only `readme.txt` with no sensitive data

### 2. Discovery — Macie Enabled

Macie is enabled at the account level. It automatically discovers all S3 buckets and evaluates them for sensitive data.

### 3. Classification — Macie Job

A one-time classification job scans the sensitive bucket for managed data identifiers:

| Identifier | Detects |
|------------|---------|
| `CREDIT_CARD_NUMBER` | Major card formats |
| `US_SOCIAL_SECURITY_NUMBER` | SSN format |
| `EMAIL_ADDRESS` | Email patterns |

### 4. Findings — Macie Dashboard

Findings appear in the Macie console and can be exported to Security Hub.

## Architecture

```
                    ┌──────────────────┐
                    │  S3 (sensitive)  │
                    │  customers.csv   │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   Macie Account  │
                    │   (enabled)      │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
     ┌────────▼─────────┐       ┌──────────▼────────┐
     │ Classification   │       │ Findings &        │
     │ Job (one-time)   │       │ Dashboard         │
     └──────────────────┘       └───────────────────┘
```

## References

- [Amazon Macie](https://docs.aws.amazon.com/macie/latest/user/)
- [Managed Data Identifiers](https://docs.aws.amazon.com/macie/latest/user/managed-data-identifiers.html)
