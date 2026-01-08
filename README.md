# terraform-aws-ssm-ec2

Terraform module that provisions an EC2 instance managed via AWS Systems Manager (SSM) without requiring SSH access.

## Features

- **SSM access** - Connect via Session Manager without SSH keys or bastion hosts
- **Amazon Linux 2023** - Latest AL2023 AMI (x86_64 or arm64)
- **Security hardened** - IMDSv2 required, encrypted root volume, no public IP by default
- **Flexible IAM** - Auto-creates SSM role or uses existing instance profile
- **Additional policies** - Attach extra IAM policies for S3, DynamoDB, etc.
- **Configurable storage** - gp3 volumes with customizable size, IOPS, and throughput
- **Optional SSH** - Key pair support for hybrid access scenarios

## Usage

### Basic Example

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "bastion"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.micro"

  tags = {
    Environment = "production"
  }
}

# Connect via SSM
# aws ssm start-session --target <instance_id>
```

### With Custom AMI and Storage

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "app-server"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.medium"

  ami_id = "ami-0123456789abcdef0"

  root_volume_size = 50
  root_volume_type = "gp3"
  root_volume_iops = 4000
  root_volume_throughput = 250

  tags = {
    Environment = "production"
  }
}
```

### With Graviton (ARM64)

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name             = "arm-server"
  vpc_id           = "vpc-12345678"
  subnet_id        = "subnet-12345678"
  instance_type    = "t4g.micro"
  ami_architecture = "arm64"

  tags = {
    Environment = "production"
  }
}
```

### With Additional IAM Policies

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "worker"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.small"

  additional_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
  ]

  tags = {
    Environment = "production"
  }
}
```

### With Existing Instance Profile

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "custom-role"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.micro"

  create_iam_instance_profile = false
  iam_instance_profile        = "my-existing-profile"

  tags = {
    Environment = "production"
  }
}
```

### With Public IP and SSH Access

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "public-server"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.micro"

  associate_public_ip_address = true
  key_name                    = "my-key-pair"

  ingress_rules = [
    {
      description = "SSH from office"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["203.0.113.0/24"]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

### With User Data

```hcl
module "ssm_instance" {
  source = "ogulcanaydogan/ssm-ec2/aws"

  name          = "configured-server"
  vpc_id        = "vpc-12345678"
  subnet_id     = "subnet-12345678"
  instance_type = "t3.micro"

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
  EOF

  user_data_replace_on_change = true

  tags = {
    Environment = "production"
  }
}
```

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `name` | Name prefix for all resources | `string` |
| `vpc_id` | VPC ID | `string` |
| `subnet_id` | Subnet ID | `string` |

### Instance Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `instance_type` | EC2 instance type | `string` | `"t3.micro"` |
| `ami_id` | Custom AMI ID (defaults to Amazon Linux 2023) | `string` | `null` |
| `ami_architecture` | Architecture for default AMI (x86_64, arm64) | `string` | `"x86_64"` |
| `key_name` | SSH key pair name | `string` | `null` |
| `monitoring` | Enable detailed monitoring | `bool` | `false` |

### Network

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `security_group_ids` | Existing security group IDs | `list(string)` | `[]` |
| `ingress_rules` | Ingress rules for created security group | `list(object)` | `[]` |
| `associate_public_ip_address` | Associate public IP | `bool` | `false` |
| `private_ip` | Specific private IP | `string` | `null` |

### IAM

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `create_iam_instance_profile` | Create IAM role for SSM | `bool` | `true` |
| `iam_instance_profile` | Existing instance profile name | `string` | `null` |
| `additional_iam_policies` | Additional policy ARNs to attach | `list(string)` | `[]` |

### Storage

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `root_volume_size` | Root volume size in GB | `number` | `8` |
| `root_volume_type` | Root volume type | `string` | `"gp3"` |
| `root_volume_iops` | IOPS for gp3/io1/io2 volumes | `number` | `null` |
| `root_volume_throughput` | Throughput for gp3 volumes (MiB/s) | `number` | `null` |
| `delete_on_termination` | Delete root volume on termination | `bool` | `true` |

### Metadata

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `http_endpoint` | IMDS endpoint (enabled/disabled) | `string` | `"enabled"` |
| `http_tokens` | IMDSv2 tokens (required/optional) | `string` | `"required"` |
| `http_put_response_hop_limit` | IMDS hop limit | `number` | `1` |

### User Data

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `user_data` | User data script | `string` | `null` |
| `user_data_base64` | Base64-encoded user data | `string` | `null` |
| `user_data_replace_on_change` | Replace instance on user data change | `bool` | `false` |

### Other

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `tags` | Tags for all resources | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_arn` | EC2 instance ARN |
| `private_ip` | Private IP address |
| `public_ip` | Public IP address (if applicable) |
| `private_dns` | Private DNS name |
| `public_dns` | Public DNS name (if applicable) |
| `availability_zone` | Availability zone |
| `ami_id` | AMI ID used |
| `security_group_id` | Created security group ID |
| `security_group_arn` | Created security group ARN |
| `iam_role_arn` | IAM role ARN |
| `iam_role_name` | IAM role name |
| `instance_profile_arn` | Instance profile ARN |
| `instance_profile_name` | Instance profile name |
| `ssm_start_session_command` | SSM session command |

## Connecting via SSM

After deployment, connect using AWS CLI:

```bash
# Using instance ID
aws ssm start-session --target i-0123456789abcdef0

# Using Terraform output
aws ssm start-session --target $(terraform output -raw instance_id)
```

## Examples

See [`examples/basic`](./examples/basic) for a complete configuration.
