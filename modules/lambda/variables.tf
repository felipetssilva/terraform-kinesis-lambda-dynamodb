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
  type = string

}

variable "aws_iam_role_name" {
  type = string
}

variable "lambda_execution_attachment"{
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

