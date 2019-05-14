data "aws_ecs_task_definition" "application" {
  task_definition = "${aws_ecs_task_definition.application.family}"
  depends_on      = ["aws_ecs_task_definition.application"]
}

resource "aws_ecs_service" "application" {
  name    = "${var.name}"
  cluster = "${data.aws_ecs_cluster.ecs.arn}"

  task_definition                    = "${aws_ecs_task_definition.application.family}:${max("${aws_ecs_task_definition.application.revision}", "${data.aws_ecs_task_definition.application.revision}")}"
  desired_count                      = "${var.min_capacity}"
  launch_type                        = "EC2"
  deployment_maximum_percent         = "${var.max_healthy}"
  deployment_minimum_healthy_percent = "${var.min_healthy}"
  health_check_grace_period_seconds  = "${var.healthcheck_grace}"
  scheduling_strategy                = "${var.scheduling_strategy}"

  load_balancer {
    container_name   = "${var.name}"
    container_port   = "${var.port}"
    target_group_arn = "${aws_lb_target_group.application.arn}"
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }

  depends_on = ["aws_iam_role.ecs_task_execution"]

  tags = "${var.tags}"
}
