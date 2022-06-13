# https://docs.aws.amazon.com/ko_kr/codepipeline/latest/userguide/tutorials-ecs-ecr-codedeploy.html#tutorials-ecs-ecr-codedeploy-pipeline
# 5단계: CodeDeploy 애플리케이션 및 배포 그룹 만들기 (ECS 컴퓨팅 플랫폼)

# CodeDeploy Application
resource "aws_codedeploy_app" "this" {
  name = "${local.prefix}-${local.tags["tier"]}-pipeline"
  compute_platform = "ECS"

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-${local.tags["tier"]}-pipeline"
    }
  )
}

# CodeDeploy Deployment Group
## IAM Role
resource "aws_iam_role" "codedeploy" {
  name = "${local.prefix}-${local.tags["tier"]}-pipeline-role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "codedeploy.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy-attach" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role = aws_iam_role.codedeploy.name
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "this" {
  deployment_group_name = "${local.prefix}-${local.tags["tier"]}-deploy-group"

  app_name = aws_codedeploy_app.this.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn = aws_iam_role.codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.this.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http_forward.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      test_traffic_route {
        listener_arns = [aws_lb_listener.test_forward.arn]
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }
}

