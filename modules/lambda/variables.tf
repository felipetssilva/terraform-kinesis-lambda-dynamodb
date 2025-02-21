variable "kinesis_stream_arn" {
    type = string
}
variable "aws_region" {
  default = "us-east-1"
}
variable "environment" {
  description = "Environment name we are building"
  default     = "realtime_data"
}

variable "lambda_filename" {
  description = "Filename of the lambda code"
  default     = "realtime_data_consume"
}

variable "lambda_function_name" {
  default = "aws_lambda_function.realtime_data_consume.function_name"
}

variable "aws_iam_role_name" {
  default = "aws_iam_role_name"  
}

variable "lambda_execution_attachment"{
  default = "aws_iam_policy_attachment.lambda_execution_policy_attachment"
}

variable "dynamodb_table_name" {
  default = "aws_dynamodb_table.realtime-data-table.name"
}