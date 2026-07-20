# ==============================================================================
# Cost estimate — SDCI Lab 05 (AWS)
#
# RESOURCE                     ESTIMATED DAILY COST    NOTES
# ---------------------------  ----------------------  ----------------------------
# VPC + Subnet + IGW           $0.00                  Free
# Security Group               $0.00                  Free
# VPC Flow Logs to CW          ~$0.02                 $0.50/GB ingested; minimal
# CloudWatch Log Group          $0.00                  Free tier: 5 GB ingestion
# Metric Filter                 $0.00                  Free
# CloudWatch Alarm              $0.00                  Free tier: 10 alarms
# SNS Topic                    $0.00                  Free tier: 1M publishes
# EC2 t2.micro                 $0.00                  Free tier eligible
# Security Hub                 $0.00                  30-day free trial
# ---------------------------------------------------------------
# TOTAL                        ~$0.02/day
# ==============================================================================
