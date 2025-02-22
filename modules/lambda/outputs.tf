

output "lambda_function_name" {
  value = "aws_lambda_function.realtime_data_consume.function_name"
}

output "aws_iam_role_name" {
  value = "aws_iam_role_name"  
}

output "lambda_execution_attachment"{
  value = "aws_iam_policy_attachment.lambda_execution_policy_attachment"
}

output "dynamodb_table_name" {
  value = "aws_dynamodb_table.realtime-data-table.name"
}

output "kinesis_stream_arn" {
  value = "aws_kinesis_stream.realtime-data-stream.arn"
  
}