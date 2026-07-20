variable "bastion_public_key" {
  description = "Public SSH key content for bastion access. Generate with 'ssh-keygen -t ed25519' and paste the .pub file contents here."
  type        = string
  default     = ""

  validation {
    condition     = length(var.bastion_public_key) > 0
    error_message = "You must provide a public SSH key for bastion access. Generate one with: ssh-keygen -t ed25519 -f ~/.ssh/sdci-lab"
  }
}
