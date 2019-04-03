module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.7.0"

  container_name  = "${var.name}"
  container_image = "${var.image == "" ? aws_ecr_repository.application.repository_url : var.image}"

  #container_image = "${aws_ecr_repository.example.repository_url}"

  container_cpu    = "${var.cpu}"
  container_memory = "${var.memory}"
  port_mappings = [
    {
      containerPort = "${var.port}"
      hostPort      = "${var.port}"
      protocol      = "tcp"
    },
  ]
  log_options = [
    {
      "awslogs-region"        = "${data.aws_region.current.name}"
      "awslogs-group"         = "${aws_cloudwatch_log_group.application_logs.name}"
      "awslogs-stream-prefix" = "ecs"
    },
  ]
  environment = ["${var.environment}"]
  secrets     = ["${var.secrets}"]
}
