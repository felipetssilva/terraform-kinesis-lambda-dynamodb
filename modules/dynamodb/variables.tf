variable "environment" {
  description = "Environment name we are building"
  default     = "realtime_data"
}

variable "lambda_filename" {
  description = "Filename of the lambda code"
  default     = "realtime_data_consume"
}

variable "dynamodb_table_name" {
  type = string

}  
variable "dynamodb_table_arn" {
  type = string

}  