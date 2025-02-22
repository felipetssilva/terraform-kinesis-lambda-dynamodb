variable "app_image" {
    default = "ozoski/custom-python-app:latest"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "dynamodb_table_arn" {
    type = string
}

variable "kinesis_stream_arn" {
    type = string
}

variable "dynamo_table_name" {
    type = string
}

variable "kinesis_stream_name" {
    type = string
}

variable "ecs_task_role_arn" {
    type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}