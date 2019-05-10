resource "aws_ecr_repository" "application" {
  count = "${var.image == "" ? 1 : 0}"
  name  = "${local.name}"

  tags = "${local.tags}"
}

output "ecr_repository" {
  value = "${aws_ecr_repository.application.*.repository_url}"
}
