variable "subnet_id" {}
variable "security_group" {}

resource "aws_efs_file_system" "efs_for_lambda" {
  creation_token = "stepsearch-efs"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs_for_lambda.id
}

# Mount target connects the file system to the subnet
resource "aws_efs_mount_target" "alpha" {
  file_system_id  = aws_efs_file_system.efs_for_lambda.id
  subnet_id       = var.subnet_id
  security_groups = [var.security_group]
}

# EFS access point used by lambda file system
resource "aws_efs_access_point" "access_point_for_lambda" {
  file_system_id = aws_efs_file_system.efs_for_lambda.id

  root_directory {
    path = "/lambda"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }
}

output "id" {
  value = aws_efs_file_system.efs_for_lambda.id
}

output "arn" {
  value = aws_efs_file_system.efs_for_lambda.arn
}

output "mount_path" {
  value = aws_efs_file_system.efs_for_lambda.dns_name
}

output "efs_access_point" {
  value = aws_efs_access_point.access_point_for_lambda.arn
}



