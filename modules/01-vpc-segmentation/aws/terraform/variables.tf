variable "region" {
  description = "AWS region for all resources. Choose the closest region to reduce latency."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "Region must be a valid AWS region (e.g., us-east-1, eu-west-2)."
  }
}

variable "creator" {
  description = "Your email or username. Used for cost tracking via the Creator tag."
  type        = string
  validation {
    condition     = length(var.creator) > 0
    error_message = "Creator must not be empty."
  }
}

variable "destroy_after" {
  description = "Date by which resources should be destroyed, in YYYY-MM-DD format."
  type        = string
  default     = "2026-08-20"
  validation {
    condition     = can(regex("^\\d{4}-\\d{2}-\\d{2}$", var.destroy_after))
    error_message = "Must be a valid date in YYYY-MM-DD format."
  }
}

variable "enable_bastion" {
  description = "Whether to deploy a t2.micro bastion host. Free tier eligible (750 hrs/month). Set to false if you prefer SSM Session Manager."
  type        = bool
  default     = true
}

variable "enable_nat" {
  description = "Whether to deploy a NAT Gateway for private instance egress. NAT Gateway costs ~$1.08/day and is NOT free tier eligible. Set to false to save cost."
  type        = bool
  default     = true
}

variable "ip_ranges" {
  description = "CIDR ranges for the VPC and subnets."
  type = object({
    vpc       = string
    public    = string
    private_a = string
    private_b = string
  })
  default = {
    vpc       = "10.0.0.0/16"
    public    = "10.0.1.0/24"
    private_a = "10.0.2.0/24"
    private_b = "10.0.3.0/24"
  }
  validation {
    condition     = alltrue([can(cidrhost(var.ip_ranges.vpc, 0)), can(cidrhost(var.ip_ranges.public, 0)), can(cidrhost(var.ip_ranges.private_a, 0)), can(cidrhost(var.ip_ranges.private_b, 0))])
    error_message = "All IP ranges must be valid CIDR notation."
  }
}

variable "module_name" {
  description = "Module identifier for tagging."
  type        = string
  default     = "01-vpc-segmentation"
}

variable "extra_tags" {
  description = "Optional additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
