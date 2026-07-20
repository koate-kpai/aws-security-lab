# ==============================================================================
# Cost estimate — SDCI Lab 04 (AWS)
#
# RESOURCE                     ESTIMATED DAILY COST    NOTES
# ---------------------------  ----------------------  ----------------------------
# VPC + Subnet                 $0.00                  Free
# Internet Gateway             $0.00                  Free
# Security Group               $0.00                  Free
# EC2 t2.micro                 $0.00                  Free tier eligible (750 hrs/mo)
# EBS gp3 8 GB                 $0.00                 $0.08/GB/mo; first 30 GB free
# SSM Session Manager          $0.00                  Free
# IAM Role + Policy            $0.00                  Free
# IAM Permission Boundary      $0.00                  Free
# S3 Bucket (STANDARD)         ~$0.00                 $0.023/GB/mo minimal usage
# ---------------------------------------------------------------
# TOTAL (best case)            ~$0.00/day             Free tier covers everything
# TOTAL (worst case)           ~$0.00/day             No billable resources
# ==============================================================================
