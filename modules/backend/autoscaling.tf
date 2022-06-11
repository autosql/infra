# ----- Application Auto Scaling
resource "aws_appautoscaling_target" "this" {
  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
  resource_id = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this" {
  for_each = var.scale_policy

  name = "${local.prefix}-${each.key}"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = each.key
    }

    target_value = each.value
  }
}
