output "sensitive_bucket" { value = aws_s3_bucket.sensitive.bucket }
output "clean_bucket" { value = aws_s3_bucket.clean.bucket }
output "macie_account_id" { value = aws_macie2_account.main.id }
output "classification_job_id" { value = aws_macie2_classification_job.scan_sensitive.id }
output "sensitive_data_file" { value = "s3://${aws_s3_bucket.sensitive.bucket}/data/customers.csv" }
