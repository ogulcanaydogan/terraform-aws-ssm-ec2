# terraform-aws-ssm-ec2

A Terraform module that provisions an EC2 instance managed via AWS Systems Manager (SSM) without requiring SSH access. The instance enforces IMDSv2, uses an encrypted root volume, and optionally creates IAM resources needed for SSM connectivity.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "ssm_ec2" {
  source = "./"  # Replace with the module source, e.g. git repo or registry address

  name          = "example-ssm-instance"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnet_ids.default.ids[0]
  instance_type = "t3.micro"
  tags = {
    Environment = "demo"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
```

Once applied, you can connect to the instance using AWS Systems Manager Session Manager:

```bash
aws ssm start-session --target $(terraform output -raw instance_id)
```

A full working configuration is provided in [`examples/basic`](examples/basic).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_id | Optional AMI ID to use for the instance. Defaults to the latest Amazon Linux 2 AMI. | `string` | `null` | no |
| create_iam_instance_profile | Whether to create an IAM role and instance profile for SSM access. | `bool` | `true` | no |
| ingress_rules | Optional ingress rules for the created security group. Ignored when security_group_ids are provided. | <pre>list(object({
  from_port   = number
  to_port     = number
  protocol    = string
  cidr_blocks = list(string)
  description = string
}))</pre> | `[]` | no |
| instance_type | EC2 instance type. | `string` | `"t3.micro"` | no |
| name | Name prefix for all resources. | `string` | n/a | yes |
| security_group_ids | List of security group IDs to associate with the instance. If empty, a security group will be created. | `list(string)` | `[]` | no |
| subnet_id | ID of the subnet to place the instance. | `string` | n/a | yes |
| tags | Additional tags to apply to resources. | `map(string)` | `{}` | no |
| user_data | Optional user data to provide when launching the instance. | `string` | `null` | no |
| vpc_id | ID of the VPC where the instance will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of the IAM role created for the instance (if created). |
| instance_arn | ARN of the EC2 instance. |
| instance_id | ID of the EC2 instance. |
| private_ip | Private IP address of the instance. |
| public_ip | Public IP address of the instance (if applicable). |
| security_group_id | ID of the created security group (if one was created). |
| ssm_start_session_command | Convenience command for starting an SSM session with the instance. |

## Examples

### Basic

See [`examples/basic`](examples/basic) for a minimal configuration using the default VPC and subnets. After applying, start an SSM session with:

```bash
aws ssm start-session --target <instance_id>
```
