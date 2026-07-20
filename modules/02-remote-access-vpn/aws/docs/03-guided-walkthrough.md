# Module 02: Remote Access VPN — Guided Walkthrough (AWS)

**Time**: 45 min | **Cost**: $0.00

## Step 1: Deploy

```powershell
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

## Step 2: Download VPN Config

```bash
# Export client configuration
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id $(terraform output -raw client_vpn_endpoint_id) \
  --output text > sdci-lab-02.ovpn

# Export client certificate and key
aws acm export-certificate \
  --certificate-arn $(terraform output -raw client_certificate_arn) \
  --passphrase "sdci-lab" \
  --output text
```

## Step 3: Connect

Install OpenVPN, then:

```bash
sudo openvpn sdci-lab-02.ovpn
```

## Step 4: Test

```bash
ping $(terraform output -raw workload_private_ip)
```

## Step 5: Clean Up

```powershell
terraform destroy -auto-approve
```
