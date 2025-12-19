output "instance_id" {
  value       = module.ssm_ec2.instance_id
  description = "ID of the example EC2 instance."
}

output "ssm_start_session_command" {
  value       = module.ssm_ec2.ssm_start_session_command
  description = "Command to start an SSM session with the example instance."
}
