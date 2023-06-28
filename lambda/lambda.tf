variable "lambda_name" {}
variable "layers" {}
variable "archive_file" {}
variable "ssm_parameter_name" {}
variable "os_uri" {}
variable "master_user" {}

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

  environment {
    variables = {
      SSM_PARAMETER = var.ssm_parameter_name
      OS_URI        = var.os_uri
      MASTER_USER   = var.master_user
    }
  }
}

output "lambda_arn" {
  value = aws_lambda_function.test_lambda.arn
}
