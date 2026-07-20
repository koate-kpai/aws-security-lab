variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "creator" {
  description = "Your email for cost tracking."
  type        = string
  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator required."
  }
}

variable "destroy_after" {
  type    = string
  default = "2026-08-20"
}

variable "module_name" {
  type    = string
  default = "02-remote-access-vpn"
}

variable "extra_tags" {
  type    = map(string)
  default = {}
}

variable "vpc_cidr" {
  description = "CIDR for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "client_cidr" {
  description = "CIDR for the Client VPN endpoint (must not overlap with VPC)."
  type        = string
  default     = "192.168.0.0/16"
}
