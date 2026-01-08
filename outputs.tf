output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the instance (if applicable)."
  value       = aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the instance."
  value       = aws_instance.this.private_dns
}

output "public_dns" {
  description = "Public DNS name of the instance (if applicable)."
  value       = aws_instance.this.public_dns
}

output "availability_zone" {
  description = "Availability zone of the instance."
  value       = aws_instance.this.availability_zone
}

output "ami_id" {
  description = "AMI ID used for the instance."
  value       = aws_instance.this.ami
}

output "security_group_id" {
  description = "ID of the created security group (if created)."
  value       = try(aws_security_group.this[0].id, null)
}

output "security_group_arn" {
  description = "ARN of the created security group (if created)."
  value       = try(aws_security_group.this[0].arn, null)
}

output "iam_role_arn" {
  description = "ARN of the IAM role (if created)."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of the IAM role (if created)."
  value       = try(aws_iam_role.this[0].name, null)
}

output "instance_profile_arn" {
  description = "ARN of the instance profile (if created)."
  value       = try(aws_iam_instance_profile.this[0].arn, null)
}

output "instance_profile_name" {
  description = "Name of the instance profile (if created)."
  value       = try(aws_iam_instance_profile.this[0].name, null)
}

output "ssm_start_session_command" {
  description = "AWS CLI command to start an SSM session."
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}
