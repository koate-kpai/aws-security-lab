output "client_vpn_endpoint_id" {
  description = "Client VPN endpoint ID."
  value       = aws_ec2_client_vpn_endpoint.main.id
}

output "client_vpn_dns_name" {
  description = "DNS name for the Client VPN endpoint. Use this in the OpenVPN client."
  value       = aws_ec2_client_vpn_endpoint.main.dns_name
}

output "client_certificate_arn" {
  description = "ARN of the client certificate."
  value       = aws_acm_certificate.client.arn
}

output "workload_private_ip" {
  description = "Private IP of the workload instance."
  value       = aws_instance.workload.private_ip
}

output "download_client_config" {
  description = "Command to download the client VPN configuration."
  value = <<-EOT
    # Download the VPN client configuration
    aws ec2 export-client-vpn-client-configuration \
      --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.main.id} \
      --output text > sdci-lab-02.ovpn

    # Download the client certificate and key (requires ACM import)
    aws acm export-certificate \
      --certificate-arn ${aws_acm_certificate.client.arn} \
      --passphrase $(openssl rand -base64 32) \
      --output text

    # Connect using OpenVPN:
    sudo openvpn sdci-lab-02.ovpn

    # From the VPN-connected machine, ping the workload:
    ping ${aws_instance.workload.private_ip}
  EOT
}

output "cost_warning" {
  value = <<-EOT
    ╔══════════════════════════════════════════════════════╗
    ║  COST WARNING                                        ║
    ╠══════════════════════════════════════════════════════╣
    ║ Client VPN: FREE (first 1,000 hrs/month)            ║
    ║ t2.micro workload: FREE (free tier)                 ║
    ║ ACM certificates: FREE                              ║
    ║                                                      ║
    ║ Total: $0.00/day (within free tier)                  ║
    ╚══════════════════════════════════════════════════════╝
  EOT
}
