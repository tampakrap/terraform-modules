/*
 * Generate user_data from template file
 */
data "template_file" "user_data" {
  template = "${file("${path.module}/default-user-data.sh")}"

  vars {
    ecs_cluster_name = "${var.cluster_name}"
  }
}

/*
 * Create Launch Configuration
 */
resource "aws_launch_configuration" "lc" {
  image_id             = "${data.aws_ami.ecs_ami.id}"
  name_prefix          = "${var.cluster_name}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.ecsInstanceProfile.id}"
  security_groups      = ["${var.security_groups}"]
  user_data            = "${var.user_data != "false" ? var.user_data : data.template_file.user_data.rendered}"
  key_name             = "${var.ssh_key_name}"

  root_block_device {
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
 * Create Auto-Scaling Group
 */
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.cluster_name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]
  min_size                  = "${var.min_size}"
  max_size                  = "${var.max_size}"
  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  default_cooldown          = "${var.default_cooldown}"
  termination_policies      = ["${var.termination_policies}"]
  launch_configuration      = "${aws_launch_configuration.lc.id}"

  tags = ["${concat(
    list(
      map("key", "ecs_cluster", "value", var.cluster_name, "propagate_at_launch", true)
    ),
    var.tags
  )}"]

  protect_from_scale_in = "${var.protect_from_scale_in}"

  lifecycle {
    create_before_destroy = true
  }
}

/*
 * Create autoscaling policies
 */
resource "aws_autoscaling_policy" "up" {
  name                   = "${var.cluster_name}-ecs-instance-scale-up"
  scaling_adjustment     = "${var.scaling_adjustment_up}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.policy_cooldown}"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.alarm_actions_enabled ? 1 : 0}"
}

resource "aws_autoscaling_policy" "down" {
  name                   = "${var.cluster_name}-ecs-instance-scale-down"
  scaling_adjustment     = "${var.scaling_adjustment_down}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.policy_cooldown}"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.alarm_actions_enabled ? 1 : 0}"
}

/*
 * Create CloudWatch alarms to trigger scaling of ASG
 */
resource "aws_cloudwatch_metric_alarm" "scaleUp" {
  alarm_name          = "${var.cluster_name}-scaleUp"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  threshold           = "${var.alarm_threshold_up}"
  actions_enabled     = "${var.alarm_actions_enabled}"
  count               = "${var.alarm_actions_enabled ? 1 : 0}"
  alarm_actions       = ["${aws_autoscaling_policy.up.arn}"]

  metric_query {
    id = "cpu_reservation"

    metric {
      metric_name = "CPUReservation"
      namespace   = "AWS/ECS"
      period      = "${var.alarm_period}"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
      }
    }
  }

  metric_query {
    id = "cpu_utilization"

    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      period      = "${var.alarm_period}"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
      }
    }
  }

  metric_query {
    id = "mem_utilization"

    metric {
      metric_name = "Memory­Utilization"
      namespace   = "AWS/ECS"
      period      = "${var.alarm_period}"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
      }
    }
  }

  metric_query {
    id = "mem_reservation"

    metric {
      metric_name = "Memory­Reservation"
      namespace   = "AWS/ECS"
      period      = "${var.alarm_period}"
      stat        = "Average"

      dimensions = {
        ClusterName = "${var.cluster_name}"
      }
    }
  }

  metric_query {
    id          = "max"
    label       = "CpuOrMemUtilization"
    expression  = "MAX(METRICS())"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "scaleDown" {
  alarm_name          = "${var.cluster_name}-scaleDown"
  alarm_description   = "ECS cluster scaling metric under threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "${var.scaling_metric_name}"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = "${var.alarm_period}"
  threshold           = "${var.alarm_threshold_down}"
  actions_enabled     = "${var.alarm_actions_enabled}"
  count               = "${var.alarm_actions_enabled ? 1 : 0}"
  alarm_actions       = ["${aws_autoscaling_policy.down.arn}"]

  dimensions {
    ClusterName = "${var.cluster_name}"
  }
}

/*
 * ASG related variables
 */

// Reqiured:
variable "security_groups" {
  description = "List of security groups to place instances into"
  type        = "list"
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs to place instances into"
  type        = "list"
}

// Optional:
variable "instance_type" {
  default     = "t2.micro"
  description = "See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes"
}

variable "user_data" {
  description = "Bash code for inclusion as user_data on instances. By default contains minimum for registering with ECS cluster"
  default     = "false"
}

variable "root_volume_size" {
  default = "8"
}

variable "min_size" {
  default = "1"
}

variable "max_size" {
  default = "5"
}

variable "health_check_type" {
  default = "EC2"
}

variable "health_check_grace_period" {
  default = "300"
}

variable "default_cooldown" {
  default = "30"
}

variable "termination_policies" {
  type        = "list"
  default     = ["Default"]
  description = "The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
}

variable "protect_from_scale_in" {
  default = false
}

variable "tags" {
  type        = "list"
  description = "List of maps with keys: 'key', 'value', and 'propagate_at_launch'"

  default = [
    {
      key                 = "created_by"
      value               = "terraform"
      propagate_at_launch = true
    },
  ]
}

variable "scaling_adjustment_up" {
  default     = "1"
  description = "How many instances to scale up by when triggered"
}

variable "scaling_adjustment_down" {
  default     = "-1"
  description = "How many instances to scale down by when triggered"
}

variable "scaling_metric_name" {
  default     = "CPUReservation"
  description = "Options: CPUReservation or MemoryReservation"
}

variable "adjustment_type" {
  default     = "ChangeInCapacity"
  description = "Options: ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity"
}

variable "policy_cooldown" {
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
}

variable "evaluation_periods" {
  default     = "2"
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "alarm_period" {
  default     = "120"
  description = "The period in seconds over which the specified statistic is applied."
}

variable "alarm_threshold_up" {
  default     = "100"
  description = "The value against which the specified statistic is compared."
}

variable "alarm_threshold_down" {
  default     = "45"
  description = "The value against which the specified statistic is compared."
}

variable "alarm_actions_enabled" {
  default = true
}

variable "ssh_key_name" {
  default     = ""
  description = "Name of SSH key pair to use as default (ec2-user) user key"
}
