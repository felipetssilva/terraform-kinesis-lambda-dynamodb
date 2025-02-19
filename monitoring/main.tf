#############################
# PROMETHEUS CONTAINER DEFINITION
#############################

resource "aws_ecs_task_definition" "prometheus" {
  family                   = "prometheus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

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
        access_point_id = aws_efs_access_point.prometheus.id
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


resource "aws_ecs_service" "prometheus_service" {
  name            = "prometheus-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.prometheus.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.monitoring_sg.id]
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
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

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
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [aws_security_group.monitoring_sg.id]
  }
}
