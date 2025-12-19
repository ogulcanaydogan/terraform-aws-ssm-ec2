variable "name" {
  description = "Name prefix for all resources."
  type        = string

  validation {
    condition     = length(trim(var.name)) > 0
    error_message = "A non-empty name must be provided."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the instance will be created."
  type        = string

  validation {
    condition     = length(trim(var.vpc_id)) > 0
    error_message = "A valid VPC ID must be provided."
  }
}

variable "subnet_id" {
  description = "ID of the subnet to place the instance."
  type        = string

  validation {
    condition     = length(trim(var.subnet_id)) > 0
    error_message = "A valid subnet ID must be provided."
  }
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = length(trim(var.instance_type)) > 0
    error_message = "Instance type cannot be empty."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  description = "Optional AMI ID to use for the instance. Defaults to the latest Amazon Linux 2 AMI."
  type        = string
  default     = null
}

variable "create_iam_instance_profile" {
  description = "Whether to create an IAM role and instance profile for SSM access."
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance. If empty, a security group will be created."
  type        = list(string)
  default     = []
}

variable "ingress_rules" {
  description = "Optional ingress rules for the created security group. Ignored when security_group_ids are provided."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : rule.from_port <= rule.to_port
    ])
    error_message = "Each ingress rule must have from_port less than or equal to to_port."
  }
}

variable "user_data" {
  description = "Optional user data to provide when launching the instance."
  type        = string
  default     = null
}
