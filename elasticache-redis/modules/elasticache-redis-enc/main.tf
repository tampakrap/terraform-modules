locals {
  name            = "${var.project}-${var.app}-${var.stage}"
  name_underscore = "${var.project}_${var.app}_${var.stage}"

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

resource "aws_elasticache_subnet_group" "default" {
  name       = "${lower(local.name)}"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_replication_group" "redis_enc" {
  replication_group_id          = "${lower(substr(local.name, 0, 20))}"
  replication_group_description = "Replication group for Redis"
  automatic_failover_enabled    = "${var.automatic_failover_enabled}"
  number_cache_clusters         = "${var.desired_clusters}"
  node_type                     = "${var.instance_type}"
  parameter_group_name          = "${var.parameter_group}"
  subnet_group_name             = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids            = ["${var.security_group_ids}"]
  port                          = "${var.port}"
  maintenance_window            = "${var.maintenance_window}"
  at_rest_encryption_enabled    = "true"
  transit_encryption_enabled    = "true"
  auth_token                    = "${var.auth_token}"
  tags                          = "${local.tags}"
}
