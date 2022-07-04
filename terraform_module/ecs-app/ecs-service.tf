resource "aws_ecs_cluster" "ecs_fargate" {
  name = "fargate-cluster"
}


resource "aws_ecs_service" "abc" {
  name                               = var.service_name
  cluster                            = aws_ecs_cluster.ecs_fargate.id
  task_definition                    = aws_ecs_task_definition.abc.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  platform_version                   = "1.4.0"
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_task_sg.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_alb_target_group.arn
    container_name   = "abc"
    container_port   = var.service_port
  }

}

resource "aws_ecs_task_definition" "abc" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs_role.arn
  memory                   = 512
  cpu                      = 256
  container_definitions = jsonencode([
    {
      name      = var.service_name
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.eu-west-1.amazonaws.com/${var.repo_name}:${var.app_version}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.service_port
          hostPort      = var.service_port
        }
      ]
      environment = [
        {
          "name" : "version",
          "value" : var.app_version
        }
      ]
    }
  ])
}


