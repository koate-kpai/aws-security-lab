# ------------------------------------------------------------------------------
# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (AWS)
# main.tf
#
# Uses Amazon Macie to discover, classify, and protect sensitive data in S3.
#
# Pipeline:
#   1. S3 bucket stores sample sensitive data (fake PII)
#   2. Macie is enabled and discovers the bucket
#   3. Macie classification job scans for PII (credit cards, SSNs, etc.)
#   4. Findings are viewable in Macie dashboard and Security Hub
#
# COST: Macie 30-day free trial; S3 minimal (~$0.00/day)
# --------------------------------------------------------------------------

# S3 buckets — one with sensitive data, one clean (control)
resource "random_id" "suffix" { byte_length = 4 }

resource "aws_s3_bucket" "sensitive" {
  bucket = "${local.name_prefix}-sensitive-${random_id.suffix.hex}"
  force_destroy = true
  tags = local.tags
}

resource "aws_s3_bucket" "clean" {
  bucket = "${local.name_prefix}-clean-${random_id.suffix.hex}"
  force_destroy = true
  tags = local.tags
}

resource "aws_s3_bucket_versioning" "sensitive" {
  bucket = aws_s3_bucket.sensitive.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_versioning" "clean" {
  bucket = aws_s3_bucket.clean.id
  versioning_configuration { status = "Enabled" }
}

# Sample sensitive data file (simulated PII)
resource "aws_s3_object" "customers_csv" {
  bucket  = aws_s3_bucket.sensitive.bucket
  key     = "data/customers.csv"
  content = <<-EOT
name,email,phone,ssn,cc_number
Alice Smith,alice@example.com,555-0101,123-45-6789,4111-1111-1111-1111
Bob Jones,bob@test.org,555-0102,987-65-4321,5500-0000-0000-0004
Carol Lee,carol@demo.net,555-0103,456-78-9012,3400-0000-0000-0009
EOT
}

resource "aws_s3_object" "clean_file" {
  bucket  = aws_s3_bucket.clean.bucket
  key     = "readme.txt"
  content = "This bucket contains no sensitive data."
}

# --------------------------------------------------------------------------
# AMAZON MACIE — sensitive data discovery
# --------------------------------------------------------------------------
resource "aws_macie2_account" "main" {
  finding_publishing_frequency = "FIFTEEN_MINUTES"
  status                       = "ENABLED"
}

# Macie classification job — scans the sensitive bucket for PII
resource "aws_macie2_classification_job" "scan_sensitive" {
  job_type = "ONE_TIME"
  name     = "${local.name_prefix}-scan-sensitive"
  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sensitive.bucket]
    }
    scoping {
      excludes {
        and {
          simple_scope_term {
            key          = "OBJECT_EXTENSION"
            value        = "txt"
            comparator   = "NE"
          }
        }
      }
    }
  }
  tags = local.tags
}

data "aws_caller_identity" "current" {}
