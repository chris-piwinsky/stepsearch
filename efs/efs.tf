resource "aws_efs_file_system" "my_efs" {
  creation_token = "stepsearch-efs"

  lifecycle {
    create_before_destroy = true
  }
}

output "id" {
  value = aws_efs_file_system.my_efs.id
}

output "arn" {
  value = aws_efs_file_system.my_efs.arn
}

output "mount_path" {
  value = aws_efs_file_system.my_efs.dns_name
}




