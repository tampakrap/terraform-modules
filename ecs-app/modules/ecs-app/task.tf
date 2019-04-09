resource "aws_ecs_task_definition" "application" {
  family = "${local.name}"

  execution_role_arn = "${aws_iam_role.ecs_task_execution.arn}"
  task_role_arn      = "${aws_iam_role.ecs_task_execution.arn}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "${var.cpu}"
  memory = "${var.memory}"

  container_definitions = "${module.container_definition.json}"

  tags = "${local.tags}"
}
