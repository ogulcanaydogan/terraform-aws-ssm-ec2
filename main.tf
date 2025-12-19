locals {
  create_security_group = length(var.security_group_ids) == 0
  ami_id                = coalesce(var.ami_id, data.aws_ssm_parameter.al2.value)
  tags                  = merge({ Name = var.name }, var.tags)
}

data "aws_ssm_parameter" "al2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_security_group" "this" {
  count       = local.create_security_group ? 1 : 0
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
  vpc_id      = var.vpc_id

  tags = local.tags
}

resource "aws_security_group_rule" "egress_all" {
  count             = local.create_security_group ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this[0].id
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

resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name}-ssm-role"

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
  count      = var.create_iam_instance_profile ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = aws_iam_role.this[0].name
}

resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = local.create_security_group ? aws_security_group.this[*].id : var.security_group_ids
  iam_instance_profile        = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : null
  user_data                   = var.user_data

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = local.tags
}
