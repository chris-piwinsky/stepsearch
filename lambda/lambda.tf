variable "lambda_name" {}
variable "layers" {}
variable "archive_file" {}
variable "security_group_ids" {}
variable "subnet_ids" {}
variable "environment_variables" {}
variable "efs_access_point" {}


resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = var.archive_file["output_path"]
  function_name    = var.lambda_name
  role             = aws_iam_role.os_role.arn
  handler          = "lambda_function.lambda_handler"
  layers           = var.layers
  timeout          = 120
  source_code_hash = var.archive_file["output_base64sha256"]

  runtime = "python3.9"

  file_system_config {
    # EFS file system access point ARN
    arn = var.efs_access_point

    # Local mount path inside the lambda function. Must start with '/mnt/'.
    local_mount_path = "/mnt/efs"
  }

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }

  environment {
    variables = var.environment_variables
  }
}

output "lambda_arn" {
  value = aws_lambda_function.test_lambda.arn
}


