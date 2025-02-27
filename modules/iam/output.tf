output "aws_iam_role_name" {
  value = aws_iam_role.lambda_execution_role.name
}

output "aws_iam_role_arn" { 
  value = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_attachment" {
  value = "aws_iam_policy_attachment.lambda_execution_policy_attachment"
}
