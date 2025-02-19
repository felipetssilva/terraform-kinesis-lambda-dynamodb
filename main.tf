
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
  source = "./modules/alb"
}
module "dynamodb" {
  source = "./modules/dynamodb"
}
module "ecs" {
  source = "./modules/ecs"
}
module "monitoring" {
  source = "./modules/monitoring"
}
module "route53" {
  source = "./modules/route53"
}





