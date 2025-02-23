terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }
  backend "s3" {
    bucket = "s3-backend-state-tf2"
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

resource "aws_subnet" "application_subnet_1" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "app_subnet_1"
  }
}

resource "aws_subnet" "application_subnet_2" {
  vpc_id            = aws_vpc.application_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "app_subnet_2"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.application_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.application_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "subnet_1" {
  subnet_id      = aws_subnet.application_subnet_1.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id      = aws_subnet.application_subnet_2.id
  route_table_id = aws_route_table.main.id
}

module "alb" {
  source            = "./modules/alb"
  prometheus_domain = var.prometheus_domain
  grafana_domain    = var.grafana_domain
  vpc_id            = aws_vpc.application_vpc.id
  subnets           = [aws_subnet.application_subnet_1.id, aws_subnet.application_subnet_2.id]

}

module "dynamodb" {
  source              = "./modules/dynamodb"
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn


}
module "ecs" {
  source              = "./modules/ecs"
  dynamodb_table_arn  = module.dynamodb.dynamodb_table_arn
  kinesis_stream_arn  = module.kinesis.kinesis_stream_arn
  dynamo_table_name   = module.dynamodb.dynamodb_table_name
  kinesis_stream_name = module.kinesis.kinesis_stream_name
  ecs_task_role_arn   = module.ecs.ecs_task_role_arn
  vpc_id              = aws_vpc.application_vpc.id
  subnets           = [aws_subnet.application_subnet_1.id, aws_subnet.application_subnet_2.id]

}
module "monitoring" {
  source             = "./modules/monitoring"
  ecs_cluster_id     = module.ecs.ecs_cluster_id
  ecs_security_group = module.ecs.ecs_security_group
  ecs_task_role_arn  = module.ecs.ecs_task_role_arn
  vpc_id             = aws_vpc.application_vpc.id
  subnets           = [aws_subnet.application_subnet_1.id, aws_subnet.application_subnet_2.id]

}

module "route53" {
  source            = "./modules/route53"
  prometheus_domain = var.prometheus_domain
  grafana_domain    = var.grafana_domain
  alb_dns_name      = module.alb.alb_dns_name
  alb_zone_id       = module.alb.alb_zone_id
}

module "iam" {
  source                      = "./modules/iam"
  aws_iam_role_name           = module.iam.aws_iam_role_name
  lambda_execution_attachment = module.iam.lambda_execution_attachment
  dynamodb_table_arn          = module.dynamodb.dynamodb_table_arn
}

module "kinesis" {
  source              = "./modules/kinesis"
  kinesis_stream_arn  = module.kinesis.kinesis_stream_arn
  kinesis_stream_name = module.kinesis.kinesis_stream_name

}

module "lambda" {
  source                      = "./modules/lambda"
  kinesis_stream_arn          = module.kinesis.kinesis_stream_arn
  aws_iam_role_arn            = module.iam.aws_iam_role_arn
  lambda_execution_attachment = module.iam.lambda_execution_attachment
  dynamodb_table_name         = module.dynamodb.dynamodb_table_name
  lambda_function_name        = module.lambda.lambda_function_name

}



