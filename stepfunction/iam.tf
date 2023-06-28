resource "aws_iam_role" "step_function_role" {
  name = "${var.step_name}_function_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.step_function_role.name
}

resource "aws_iam_policy" "step_function_lambda_policy" {
  name = "${var.step_name}_function_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = "*"
      },
            {
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.step_function_lambda_policy.arn
  role       = aws_iam_role.step_function_role.name
}