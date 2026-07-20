# ==============================================================================
# Cost estimate — SDCI Lab 03 (AWS)
#
# RESOURCE                  ESTIMATED DAILY COST    NOTES
# ------------------------  ----------------------  ----------------------------
# VPC + subnets              $0.00                  Free (no extra charges)
# IGW + Route Tables         $0.00                  Free
# Security Groups            $0.00                  Free
# NACLs                      $0.00                  Free
# AWS WAF Web ACL            $0.00                  ~5 free ACLs per account
# GuardDuty                  $0.00                  30-day free trial
# ALB                        ~$0.54/day             $0.0225/hr
# EC2 t2.micro               ~$0.35/day             Free tier eligible (750 hrs/mo)
# EBS gp3 20 GB              ~$0.00                 $0.08/GB/mo; first 30 GB free
# ---------------------------------------------------------------
# TOTAL (best case)          ~$0.00/day             If credits and free tier apply
# TOTAL (worst case)         ~$0.89/day             No free tier remaining
# ==============================================================================
