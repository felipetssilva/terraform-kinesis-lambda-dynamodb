variable "aws_region" {
  type = string
  default = "us-east-1"
}
variable "environment" {
  type = string
  description = "Environment name we are building"
  default     = "realtime_data"
}

variable "lambda_filename" {
  type = string
  description = "Filename of the lambda code"
  default     = "realtime_data_consume"
}

variable "kinesis_stream_name" {
  type = string
  default = "aws_kinesis_stream.realtime-data-stream.name"
}
variable "kinesis_stream_arn" {
  type = string
  default = "aws_kinesis_stream.realtime-data-stream.arn"
}