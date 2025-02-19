
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "kinesis" {
  source = "./kinesis"
}

module "dynamodb" {
  source = "./dynamodb"
}

module "lambda" {
  source = "./lambda"
}

module "iam" {
  source = "./iam"
}

module "monitoring" {
  source = "./monitoring"
}
# Include the ECS, Prometheus, and Grafana definitions 
module "ecs" {
  source = "./ecs"
}
