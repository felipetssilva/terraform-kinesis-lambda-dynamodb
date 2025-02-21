variable "environment" {
  description = "Environment name we are building"
  default     = "realtime_data"
}

variable "lambda_filename" {
  description = "Filename of the lambda code"
  default     = "realtime_data_consume"
}

variable "dynamodb_table_name" {
  default = "aws_dynamodb_table.realtime-data-table.name"
  }