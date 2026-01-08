locals {
  create_security_group = length(var.security_group_ids) == 0

  # Amazon Linux 2023 AMI path based on architecture
  ami_ssm_path = var.ami_architecture == "arm64" ? "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64" : "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"

  ami_id = coalesce(var.ami_id, data.aws_ssm_parameter.al2023.value)

  instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile

  tags = merge(var.tags, { Name = var.name })
}

# Get latest Amazon Linux 2023 AMI
data "aws_ssm_parameter" "al2023" {
  name = local.ami_ssm_path
}

# Security Group
resource "aws_security_group" "this" {
  count = local.create_security_group ? 1 : 0

  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "egress_all" {
  count = local.create_security_group ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this[0].id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "ingress" {
  for_each = local.create_security_group ? { for idx, rule in var.ingress_rules : idx => rule } : {}

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.this[0].id
  description       = each.value.description
}

# IAM Role for SSM
resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count = var.create_iam_instance_profile ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = var.create_iam_instance_profile ? toset(var.additional_iam_policies) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${var.name}-instance-profile"
  role = aws_iam_role.this[0].name

  tags = local.tags
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = local.create_security_group ? aws_security_group.this[*].id : var.security_group_ids
  iam_instance_profile        = local.instance_profile
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  private_ip                  = var.private_ip
  monitoring                  = var.monitoring

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  metadata_options {
    http_endpoint               = var.http_endpoint
    http_tokens                 = var.http_tokens
    http_put_response_hop_limit = var.http_put_response_hop_limit
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = true
    delete_on_termination = var.delete_on_termination
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [ami]
  }
}
