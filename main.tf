terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
  backend "s3" {
    bucket = "s3-backend-state-tf"
    key    = "s3-backup"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "application_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "app_vpc"
  }
}

resource "aws_subnet" "application_subnet" {
  vpc_id     = aws_vpc.application_vpc.id
  cidr_block = "10.0.0.0/24"
}

module "alb" {
  source            = "./modules/alb"
  prometheus_domain = var.prometheus_domain
  grafana_domain    = var.grafana_domain
}
module "dynamodb" {
  source              = "./modules/dynamodb"
  dynamodb_table_name   = module.dynamodb.dynamodb_table_name
  dynamodb_table_arn    = module.dynamodb.dynamodb_table_arn
  

}
module "ecs" {
  source              = "./modules/ecs"
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn
  kinesis_stream_arn  = module.kinesis.kinesis_stream_arn
  dynamo_table_name   = module.dynamodb.dynamodb_table_name
  kinesis_stream_name = module.kinesis.kinesis_stream_name
  ecs_task_role_arn   = module.ecs.ecs_task_role_arn

}
module "monitoring" {
  source             = "./modules/monitoring"
  ecs_cluster_id     = module.ecs.ecs_cluster_id
  ecs_security_group = module.ecs.ecs_security_group
  ecs_task_role_arn  = module.ecs.ecs_task_role_arn

}

module "route53" {
  source = "./modules/route53"
  route53_zone = module.alb.route53_zone
  route53_zone_id = module.alb.route53_zone_id
  prometheus_domain = var.prometheus_domain
  grafana_domain    = var.grafana_domain

}

module "iam" {
  source                      = "./modules/iam"
  aws_iam_role_name           = module.iam.aws_iam_role_name
  lambda_execution_attachment = module.iam.lambda_execution_attachment
  dynamodb_table_arn          = module.dynamodb.dynamodb_table_arn
}

module "kinesis" {
  source = "./modules/kinesis"
  kinesis_stream_arn = module.kinesis.kinesis_stream_arn
  kinesis_stream_name = module.kinesis.kinesis_stream_name

}

module "lambda" {
  source                      = "./modules/lambda"
  kinesis_stream_arn          = module.kinesis.kinesis_stream_arn
  aws_iam_role_name           = module.iam.aws_iam_role_name
  lambda_execution_attachment = module.iam.lambda_execution_attachment
  dynamodb_table_name         = module.dynamodb.dynamodb_table_name
  lambda_function_name        = module.lambda.lambda_function_name
}



