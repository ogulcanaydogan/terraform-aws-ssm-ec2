variable "name" {
  description = "Name prefix for all resources."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0 && length(var.name) <= 255
    error_message = "name must be between 1 and 255 characters."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the instance will be created."
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID (e.g., vpc-12345678)."
  }
}

variable "subnet_id" {
  description = "ID of the subnet to place the instance."
  type        = string

  validation {
    condition     = can(regex("^subnet-[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid subnet ID (e.g., subnet-12345678)."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(trimspace(var.instance_type)) > 0
    error_message = "instance_type must not be empty."
  }
}

variable "ami_id" {
  description = "AMI ID for the instance. Defaults to latest Amazon Linux 2023."
  type        = string
  default     = null
}

variable "ami_architecture" {
  description = "Architecture for the default AMI (x86_64 or arm64)."
  type        = string
  default     = "x86_64"

  validation {
    condition     = contains(["x86_64", "arm64"], var.ami_architecture)
    error_message = "ami_architecture must be x86_64 or arm64."
  }
}

# Security
variable "security_group_ids" {
  description = "Security group IDs to associate. If empty, a security group is created."
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "Ingress rules for the created security group. Ignored when security_group_ids provided."
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : rule.from_port <= rule.to_port
    ])
    error_message = "from_port must be less than or equal to to_port."
  }
}

variable "key_name" {
  description = "Key pair name for SSH access (optional, SSM is primary access method)."
  type        = string
  default     = null
}

# IAM
variable "create_iam_instance_profile" {
  description = "Create IAM role and instance profile for SSM access."
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name. Used when create_iam_instance_profile is false."
  type        = string
  default     = null
}

variable "additional_iam_policies" {
  description = "Additional IAM policy ARNs to attach to the instance role."
  type        = list(string)
  default     = []
}

# Network
variable "associate_public_ip_address" {
  description = "Associate a public IP address with the instance."
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address to assign to the instance."
  type        = string
  default     = null
}

# Storage
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "root_volume_size must be between 8 and 16384 GB."
  }
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (gp2, gp3, io1, io2, st1, sc1)."
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.root_volume_type)
    error_message = "root_volume_type must be gp2, gp3, io1, io2, st1, or sc1."
  }
}

variable "root_volume_iops" {
  description = "IOPS for gp3, io1, io2 volumes. Defaults based on volume type."
  type        = number
  default     = null
}

variable "root_volume_throughput" {
  description = "Throughput in MiB/s for gp3 volumes (125-1000)."
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_throughput == null ? true : (var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000)
    error_message = "root_volume_throughput must be between 125 and 1000 MiB/s."
  }
}

variable "delete_on_termination" {
  description = "Delete root volume on instance termination."
  type        = bool
  default     = true
}

# Monitoring
variable "monitoring" {
  description = "Enable detailed monitoring."
  type        = bool
  default     = false
}

# Metadata
variable "http_endpoint" {
  description = "Enable instance metadata endpoint (enabled or disabled)."
  type        = string
  default     = "enabled"

  validation {
    condition     = contains(["enabled", "disabled"], var.http_endpoint)
    error_message = "http_endpoint must be enabled or disabled."
  }
}

variable "http_tokens" {
  description = "IMDSv2 token requirement (required or optional)."
  type        = string
  default     = "required"

  validation {
    condition     = contains(["required", "optional"], var.http_tokens)
    error_message = "http_tokens must be required or optional."
  }
}

variable "http_put_response_hop_limit" {
  description = "HTTP PUT response hop limit for IMDS (1-64)."
  type        = number
  default     = 1

  validation {
    condition     = var.http_put_response_hop_limit >= 1 && var.http_put_response_hop_limit <= 64
    error_message = "http_put_response_hop_limit must be between 1 and 64."
  }
}

# User data
variable "user_data" {
  description = "User data script to run on instance launch."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Base64-encoded user data."
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Replace instance when user data changes."
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
