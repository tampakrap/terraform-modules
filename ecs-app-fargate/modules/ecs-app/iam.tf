# task execution role

resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_underscore}_ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = "${local.tags}"
}

# ecr access (if ecr is created)

resource "aws_iam_policy" "ecr_access" {
  count = "${var.image == "" ? 1 : 0}"

  name        = "${local.name}-ecr"
  path        = "/"
  description = "Policy for service ${local.name}-${var.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_repository" {
  count      = "${var.image == "" ? 1 : 0}"
  role       = "${aws_iam_role.ecs_task_execution.id}"
  policy_arn = "${aws_iam_policy.ecr_access.arn}"
}

# cloudwatch logs access

resource "aws_iam_policy" "logs_policy" {
  name        = "${local.name}-logs"
  path        = "/"
  description = "Policy for service ${local.name}-${var.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
    ],
      "Resource": [
        "arn:aws:logs:*:*:*"
    ]
  }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "application_logs" {
  role       = "${aws_iam_role.ecs_task_execution.id}"
  policy_arn = "${aws_iam_policy.logs_policy.arn}"
}

# custom policy

resource "aws_iam_policy" "service_policy" {
  count       = "${var.policy == "" ? 0 : 1}"
  name        = "${local.name}-${var.name}"
  path        = "/"
  description = "Policy for service ${local.name}-${var.name}"

  policy = "${var.policy}"
}

resource "aws_iam_role_policy_attachment" "service_policy" {
  count      = "${var.policy == "" ? 0 : 1}"
  role       = "${aws_iam_role.ecs_task_execution.id}"
  policy_arn = "${aws_iam_policy.service_policy.arn}"
}
