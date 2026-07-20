output "instance_id" { value = aws_instance.main.id }
output "instance_arn" { value = aws_instance.main.arn }
output "role_name" { value = aws_iam_role.main.name }
output "role_arn" { value = aws_iam_role.main.arn }
output "policy_arn" { value = aws_iam_policy.main.arn }
output "boundary_arn" { value = aws_iam_policy.boundary.arn }
output "bucket_name" { value = aws_s3_bucket.main.id }
output "ssm_command" {
  value = "aws ssm start-session --target ${aws_instance.main.id}"
}
