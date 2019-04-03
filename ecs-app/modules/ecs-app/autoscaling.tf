resource "aws_appautoscaling_target" "ecs_target" {
  count              = "${var.autoscaling ? 1 : 0}"
  max_capacity       = "${var.max_capacity}"
  min_capacity       = "${var.min_capacity}"
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = ["aws_ecs_service.application"]
}

/* metric used for auto scale */
resource "aws_cloudwatch_metric_alarm" "service_cpu_mem_high" {
  count               = "${var.autoscaling ? 1 : 0}"
  alarm_name          = "${local.name_underscore}_cpu_or_mem_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  threshold           = "${var.scale_up}"

  metric_query {
    id = "cpu"

    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      period      = "60"
      stat        = "Average"

      dimensions {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.name}"
      }
    }
  }

  metric_query {
    id = "mem"

    metric {
      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      period      = "60"
      stat        = "Average"

      dimensions {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.name}"
      }
    }
  }

  metric_query {
    id          = "MAX"
    label       = "Maximum of CPU/MEM"
    expression  = "MAX(METRICS())"
    return_data = "true"
  }

  alarm_actions = [
    "${aws_appautoscaling_policy.up.arn}",
  ]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_mem_low" {
  count               = "${var.autoscaling ? 1 : 0}"
  alarm_name          = "${local.name_underscore}_cpu_or_mem_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  threshold           = "${var.scale_down}"

  metric_query {
    id = "cpu"

    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      period      = "60"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.name}"
      }
    }
  }

  metric_query {
    id = "mem"

    metric {
      metric_name = "MemoryUtilization"
      namespace   = "AWS/ECS"
      period      = "60"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
        ServiceName = "${var.name}"
      }
    }
  }

  metric_query {
    id          = "MAX"
    label       = "Maximum of CPU/MEM"
    expression  = "MAX(METRICS())"
    return_data = "true"
  }

  alarm_actions = [
    "${aws_appautoscaling_policy.down.arn}",
  ]
}

resource "aws_appautoscaling_policy" "up" {
  count              = "${var.autoscaling ? 1 : 0}"
  name               = "${local.name_underscore}_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_target",
  ]
}

resource "aws_appautoscaling_policy" "down" {
  count              = "${var.autoscaling ? 1 : 0}"
  name               = "${local.name_underscore}_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.cooldown}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.ecs_target",
  ]
}
