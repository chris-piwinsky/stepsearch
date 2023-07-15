variable "lambda_name" {}
variable "layers" {}
variable "archive_file" {}
variable "security_group_ids" {}
variable "subnet_ids" {}
variable "environment_variables" {}
variable "efs_arn" {}


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

resource "aws_lambda_permission" "efs_access" {
  statement_id  = "AllowExecutionFromEFS-${aws_lambda_function.test_lambda.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "elasticfilesystem.amazonaws.com"
  source_arn    = var.efs_arn
}
