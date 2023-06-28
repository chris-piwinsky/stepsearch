resource "aws_sfn_state_machine" "step_function" {
  name = "${var.step_name}_function"
  role_arn = aws_iam_role.step_function_role.arn

  definition = "${var.step_function_definition}"
}

variable "step_function_definition" {}
variable "step_name" {}

output "state_machine_arn" {
  value = aws_sfn_state_machine.step_function.arn
}