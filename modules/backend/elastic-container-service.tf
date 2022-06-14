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

########################################################################
## ----- IAM ROLES
########################################################################
# ----- ECS ASSUME ROLE
data "aws_iam_policy_document" "assune_by_ecs" {
  statement {
    sid = "AllowAssumeByEcsTasks"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ----- ECS TASK ROLE
data "aws_iam_policy_document" "task_role" {
  statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"
    actions = ["ecs:DescribeClusters"]
    resources = ["${aws_ecs_cluster.this.arn}"]
  }
}

resource "aws_iam_role" "task_role" {
  name = "ecsTaskExecutionRole" 
  assume_role_policy = data.aws_iam_policy_document.assune_by_ecs.json

  tags = local.tags
}

resource "aws_iam_role_policy" "task_role" {
  role = aws_iam_role.task_role.name
  policy = data.aws_iam_policy_document.task_role.json
}

resource "aws_iam_role_policy_attachment" "task_role" {
  role = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ----- ECS EXECUTION ROLE
data "aws_iam_policy_document" "execution_role" {
  statement {
    sid = "AllowECRLogging"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "execution_role" {
  name = "${local.prefix}-${local.tags["tier"]}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assune_by_ecs.json

  tags = local.tags
}

resource "aws_iam_role_policy" "execution_role" {
  role = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}

########################################################################
## ----- ECS
########################################################################
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
    MYSQL_USERNAME = var.MYSQL_USERNAME
    MYSQL_DATABASE = var.MYSQL_DATABASE
  }
}

resource "aws_ecs_task_definition" "this" {
  family = local.prefix
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn = aws_iam_role.task_role.arn
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

# ----- ecs cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}-cluster"
  tags = local.tags
}

## ----- ecs service
resource "aws_ecs_service" "this" {
  name = "${local.prefix}-ecs-service"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = var.desired_count
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 100

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name = local.prefix
    container_port = var.container_port
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-ecs-service"
    }
  )
}
