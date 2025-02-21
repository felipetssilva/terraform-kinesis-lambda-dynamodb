data "aws_vpc" "application_vpc" {
  filter {
    name   = "tag:Name"
    values = ["app_vpc"]
  }
  }

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpc.id]
  }
}

# Create an ECS cluster
resource "aws_ecs_cluster" "data-cluster" {
  name = "realtime-data-cluster"
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for monitoring (Prometheus & Grafana)
resource "aws_security_group" "monitoring_sg" {
  name   = "monitoring-sg"
  vpc_id = data.aws_vpc.application_vpc.id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM Role for ECS Tasks (shared by app, Prometheus, and Grafana)
resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

# Policy to allow write actions to DynamoDB and Kinesis
resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs-task-policy"
  description = "Allow ECS tasks to write to DynamoDB and Kinesis"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource = var.dynamodb_table_arn,
        Effect   = "Allow"
      },
      {
        Action   = [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        Resource = var.kinesis_stream_arn,
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

#############################
# APPLICATION CONTAINER DEFINITION
#############################

resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app-container",
      image     = var.app_image, 
      essential = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      environment = [
        { name = "DYNAMODB_TABLE", value = var.dynamo_table_name }, 
        { name = "KINESIS_STREAM", value = var.kinesis_stream_name }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/app",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app_service" {
  name            = "app-service"
  cluster         = aws_ecs_cluster.data-cluster.name
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnet.default.id
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

