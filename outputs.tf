output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the instance."
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the instance (if applicable)."
  value       = aws_instance.this.public_ip
}

output "instance_arn" {
  description = "ARN of the EC2 instance."
  value       = aws_instance.this.arn
}

output "security_group_id" {
  description = "ID of the created security group (if one was created)."
  value       = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for the instance (if created)."
  value       = length(aws_iam_role.this) > 0 ? aws_iam_role.this[0].arn : null
}

output "ssm_start_session_command" {
  description = "Convenience command for starting an SSM session with the instance."
  value       = "aws ssm start-session --target ${aws_instance.this.id}"
}
