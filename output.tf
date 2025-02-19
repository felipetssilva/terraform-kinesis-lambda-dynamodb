# Output the Kinesis stream ARN
output "kinesis_stream_arn" {
  value = aws_kinesis_stream.realtime-data-stream.arn
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.realtime-data-stream.name
}
# Output the Lambda function ARN
output "lambda_function_arn" {
  value = aws_lambda_function.realtime_data_consume.arn
}

# Output the DynamoDB function ARN
output "DynamoDB_arn" {
  value = module.dynamodb.dynamodb_table_arn
  }