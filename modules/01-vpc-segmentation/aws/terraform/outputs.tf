output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "subnet_public_cidr" {
  description = "CIDR of the public subnet (Access Layer)."
  value       = var.ip_ranges.public
}

output "subnet_private_dist_cidr" {
  description = "CIDR of the distribution private subnet."
  value       = var.ip_ranges.private_a
}

output "subnet_private_core_cidr" {
  description = "CIDR of the core private subnet."
  value       = var.ip_ranges.private_b
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host. Use this to SSH in."
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : "N/A (bastion disabled)"
}

output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host."
  value       = var.enable_bastion ? "ssh -i ~/.ssh/sdci-lab ubuntu@${aws_instance.bastion[0].public_ip}" : "N/A (bastion disabled)"
}

output "verify_segmentation_command" {
  description = "Instructions to verify segmentation. SSH into bastion, then test connectivity to private instances."
  value = var.enable_bastion ? <<-EOT
    # On the bastion, install the AWS CLI and query instance IPs
    sudo apt-get update && sudo apt-get install -y awscli

    # Launch a test instance in core subnet
    aws ec2 run-instances \
      --image-id ${data.aws_ami.ubuntu.id} \
      --instance-type t2.micro \
      --subnet-id ${aws_subnet.private_b.id} \
      --security-group-ids ${aws_security_group.core.id} \
      --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=${local.name_prefix}-test-core},{Key=CostCenter,Value=SDCI-Lab}]'

    # Try SSH from bastion to core (should SUCCEED - bastion SG allows SSH)
    # Try SSH from a distribution instance to core (should FAIL - NACL blocks non-public inbound)
  EOT : "Bastion not enabled. Use AWS SSM Session Manager to access instances."
}

output "cost_warning" {
  description = "Cost reminder for this module."
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ NAT Gateway: ~$1.08/day (NOT free tier eligible)    ║
    ║ t2.micro bastion: free (750 hrs/month free tier)    ║
    ║                                                      ║
    ║ Run 'terraform destroy' when done to avoid charges.  ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
