
#############################
# PROMETHEUS CONTAINER DEFINITION
#############################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Add CloudWatch logs policy
resource "aws_iam_role_policy" "ecs_task_execution_cloudwatch" {
  name = "prometheus-ecs-task-execution-cloudwatch"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "prometheus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "prometheus",
      image     = "prom/prometheus:latest",
      essential = true,
      portMappings = [
        {
          containerPort = 9090,
          hostPort      = 9090,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/prometheus",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      },
      mountPoints = [
        {
          sourceVolume  = "prometheus-config",
          containerPath = "/etc/prometheus"
        }
      ]
    },
    {
      name      = "prometheus-ecs-discovery",
      image     = "teralytics/prometheus-ecs-discovery:latest",
      essential = true,
      command   = [
        "-config.cluster=your-ecs-cluster-name",
        "-config.scrape-interval=60s",
        "-config.write-to=/etc/prometheus/ecs_sd_targets.yml"
      ],
      environment = [
        {
          name  = "AWS_REGION",
          value = var.aws_region
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "prometheus-config",
          containerPath = "/etc/prometheus"
        }
      ]
    }
  ])

  volume {
    name = "prometheus-config"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.prometheus.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.prometheus-efs-access_point.id
      }
    }
  }
}

resource "aws_efs_file_system" "prometheus" {
  creation_token = "prometheus-efs"
  tags = {
    Name = "prometheus-efs"
  }
}

resource "aws_efs_access_point" "prometheus-efs-access_point" {
  file_system_id = aws_efs_file_system.prometheus.id
  
}

resource "aws_ecs_service" "prometheus_service" {
  name            = "prometheus-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = ["${var.ecs_security_group}"]
  }
}

#############################
# GRAFANA CONTAINER DEFINITION
#############################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana",
      image     = var.grafana_image,  # e.g., "grafana/grafana:latest"
      essential = true,
      portMappings = [
        {
          containerPort = 3000,
          hostPort      = 3000,
          protocol      = "tcp"
        }
      ],
      environment = [
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.grafana_admin_password }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/grafana",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "grafana_service" {
  name            = "grafana-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = ["${var.ecs_security_group}"]
  }
}
