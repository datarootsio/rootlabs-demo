resource "aws_cloudwatch_log_group" "rootlabs_iac" {
  name              = "rootlabs-iac-${var.environment}"
  retention_in_days = "7"
}

resource "aws_ecs_cluster" "rootlabs" {
  name               = "rootlabs-iac-${var.environment}"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "aws_ecs_task_definition" "rootlabs_iac" {
  family                   = "rootlabs-iac"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.execution.arn
  container_definitions    = <<TASK_DEFINITION
  [
    {
        "environment": [
            {"name": "ENVIRONMENT", "value": "${var.environment}"},
            {"name": "FG_COLOR", "value": "${var.fg_color}"},
            {"name": "BG_COLOR", "value": "${var.bg_color}"},
            {"name": "GUNICORN_CMD_ARGS", "value": "-b 0.0.0.0"}
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.rootlabs_iac.name}",
            "awslogs-region": "eu-west-1",
            "awslogs-stream-prefix": "container"
          }
        },
        "essential": true,
        "image": "${data.terraform_remote_state.shared.outputs.ecr_repository_url}:${var.image_tag}",
        "cpu" : 256,
        "memory": 512,
        "name": "rootlabs-iac-${var.environment}",
        "portMappings": [
            {
                "containerPort": 8000,
                "hostPort": 8000
            }
        ]
    }
  ]
  TASK_DEFINITION
}

resource "aws_lb_target_group" "rootlabs_iac" {
  name        = "rootlabs-iac-${var.environment}"
  vpc_id      = data.terraform_remote_state.shared.outputs.vpc_id
  protocol    = "HTTP"
  port        = 8000
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "rootlabs_iac" {
  listener_arn = data.terraform_remote_state.shared.outputs.alb_listener_arn
  priority     = var.environment == "production" ? 5 : 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rootlabs_iac.arn
  }

  condition {
    host_header {
      values = [var.domain_name]
    }
  }
}

resource "aws_ecs_service" "rootlabs_iac" {
  name            = "rootlabs-iac-${var.environment}"
  cluster         = aws_ecs_cluster.rootlabs.id
  task_definition = aws_ecs_task_definition.rootlabs_iac.id
  desired_count   = 1

  network_configuration {
    subnets          = data.terraform_remote_state.shared.outputs.public_subnets_ids
    security_groups  = [data.terraform_remote_state.shared.outputs.egress_security_group]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = "rootlabs-iac-${var.environment}"
    container_port   = 8000
    target_group_arn = aws_lb_target_group.rootlabs_iac.arn
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }
}

data "google_dns_managed_zone" "dns_zone" {
  name = var.dns_zone
}

resource "google_dns_record_set" "rootlabs_alb" {
  name = "${var.domain_name}."
  type = "CNAME"
  ttl  = 3600

  managed_zone = data.google_dns_managed_zone.dns_zone.name

  rrdatas = ["${data.terraform_remote_state.shared.outputs.alb_dns_name}."]
}