# ----- vpc security group
## depend_on aws_security_group.lb
resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  name = "${local.prefix}-ecs"

  ingress {
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
    from_port = var.host_port
    to_port = var.container_port

    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol = local.all_protocol
    from_port = 0
    to_port = 0
    cidr_blocks = local.all_ips
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-ecs-tasks"
    }
  )
}

# ----- ecs cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}-cluster"
  tags = local.tags
}

## ----- iam roles
## iam role policy document
data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

## iam role
resource "aws_iam_role" "ecs_task" {
  name = "${local.prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ----- task definition
data "template_file" "this" {
  template = file("${path.cwd}/${var.container_spec_path}")

  vars = {
    region = var.region
    aws_ecr_repository = aws_ecr_repository.this.repository_url
    tag = "latest"
    container_port = var.container_port
    host_port = var.host_port
    app_prefix = local.prefix
  }
}

resource "aws_ecs_task_definition" "this" {
  family = local.prefix
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task.arn
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions = data.template_file.this.rendered
  tags = merge(
    local.tags, {
      Name = "${local.prefix}-ecs-tasks"
    }
  )
}

## ----- ecs service
resource "aws_ecs_service" "this" {
  name = "${local.prefix}-ecs-service"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = var.desired_count
  launch_type = "FARGATE"

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name = local.prefix
    container_port = var.container_port
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-ecs-service"
    }
  )
}
