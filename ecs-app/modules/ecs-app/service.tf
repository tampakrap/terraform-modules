data "aws_ecs_task_definition" "application" {
  task_definition = "${aws_ecs_task_definition.application.family}"
}

resource "aws_ecs_service" "application" {
  name    = "${var.name}"
  cluster = "${data.aws_ecs_cluster.ecs.arn}"

  # task_definition                  = "${aws_ecs_task_definition.application.family}:${aws_ecs_task_definition.application.revision}"
  task_definition                    = "${aws_ecs_task_definition.application.family}:${max("${aws_ecs_task_definition.application.revision}", "${data.aws_ecs_task_definition.application.revision}")}"
  desired_count                      = "${var.service_capacity}"
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = "${var.max_healthy}"
  deployment_minimum_healthy_percent = "${var.min_healthy}"

  network_configuration {
    subnets         = ["${var.private_subnet_ids}"]
    security_groups = ["${aws_security_group.application.id}"]

    #    security_groups  = ["${var.security_group_ids}"]
    assign_public_ip = false
  }

  load_balancer {
    container_name   = "${var.name}"
    container_port   = "${var.port}"
    target_group_arn = "${aws_lb_target_group.application.arn}" # TODO - reference from this module
  }

  depends_on = ["aws_iam_role.ecs_task_execution"]

  tags = "${var.tags}"
}
