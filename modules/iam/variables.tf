variable "aws_iam_role_name" {
  type = string
  default = "aws_iam_role.lambda_execution_role.name"
}

variable "lambda_execution_attachment"{
    type = string
    default = "aws_iam_policy_attachment.lambda_execution_policy_attachment"
}