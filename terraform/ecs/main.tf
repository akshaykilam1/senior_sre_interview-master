resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

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
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "simpsons-task"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn  # Reuse existing task role
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn  # Reuse existing execution role

  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture       = "ARM64"
  }
  container_definitions    = jsonencode([{
    name      = "simpsons-simulator"
    image     = "676206917629.dkr.ecr.us-east-1.amazonaws.com/simpsons-simulator:latest"
    essential = true
    portMappings = [{
      containerPort = 4567
      hostPort      = 4567
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }
  depends_on = [aws_ecs_task_definition.this]
}

resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  description = "Allow ECS to communicate internally"
  vpc_id      = var.vpc_id
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

