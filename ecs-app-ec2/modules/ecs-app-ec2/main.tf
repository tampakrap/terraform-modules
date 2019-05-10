locals {
  name            = "${var.project}-${var.app}-${var.stage}-${var.name}"
  name_underscore = "${var.project}_${var.app}_${var.stage}_${var.name}"

  tags = "${
      merge( 
        map(
          "Name", "${local.name}",
          "Project", "${var.project}",
          "Stage", "${var.stage}",
          "App", "${var.app}"
        ), var.tags
      )
    }"
}

data "aws_region" "current" {}

data "aws_ecs_cluster" "ecs" {
  cluster_name = "${var.cluster_name}"
}

data "aws_lb" "alb" {
  arn = "${var.alb_arn}"
}
