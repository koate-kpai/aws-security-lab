output "instance_clean_id" { value = aws_instance.clean.id }
output "instance_clean_ip" { value = aws_instance.clean.public_ip }
output "instance_quarantined_id" { value = aws_instance.quarantined.id }
output "instance_quarantined_ip" { value = aws_instance.quarantined.public_ip }
output "normal_sg_id" { value = aws_security_group.normal.id }
output "quarantine_sg_id" { value = aws_security_group.quarantine.id }
output "quarantine_sg_arn" { value = aws_security_group.quarantine.arn }
output "quarantine_nacl_id" { value = aws_network_acl.quarantine.id }
output "quarantine_command" {
  value = "aws ec2 modify-instance-attribute --instance-id ${aws_instance.clean.id} --groups ${aws_security_group.quarantine.id}"
}
output "release_command" {
  value = "aws ec2 modify-instance-attribute --instance-id ${aws_instance.clean.id} --groups ${aws_security_group.normal.id}"
}
