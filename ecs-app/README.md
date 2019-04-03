## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alb\_arn | application load balancer under which target group and services will be registered | string | n/a | yes |
| app | app name | string | n/a | yes |
| autoscaling | enable autoscaling | string | `"false"` | no |
| cluster\_name | ecs cluster name where the services will be registered | string | n/a | yes |
| cooldown |  | string | `"60"` | no |
| cpu | Hard limit of CPU for the task | string | `"512"` | no |
| environment |  | list | `<list>` | no |
| healthcheck\_healthy\_threshold |  | string | `"3"` | no |
| healthcheck\_interval |  | string | `"60"` | no |
| healthcheck\_matcher |  | string | `"200"` | no |
| healthcheck\_path |  | string | `"/"` | no |
| healthcheck\_timeout |  | string | `"5"` | no |
| healthcheck\_unhealthy\_threshold |  | string | `"3"` | no |
| image | override image - disables creating ecr repository | string | `""` | no |
| log\_retention | for how many days to keep app logs | string | `"30"` | no |
| max\_capacity |  | string | `"1"` | no |
| max\_healthy |  | string | `"200"` | no |
| memory | Hard limit of MEM for the task | string | `"1024"` | no |
| min\_capacity |  | string | `"1"` | no |
| min\_healthy |  | string | `"50"` | no |
| name | name of this specific service | string | n/a | yes |
| policy | IAM Policy heredoc to use with task | string | `""` | no |
| port | port on which the service listens | string | `"80"` | no |
| priority | listener rule priority - must be unique to each ecs-app (module) | string | n/a | yes |
| private\_subnet\_ids | list of private subnets where to provision services | list | n/a | yes |
| project | project name | string | n/a | yes |
| scale\_down |  | string | `"30"` | no |
| scale\_up |  | string | `"80"` | no |
| secrets |  | list | `<list>` | no |
| service\_capacity | number of tasks that will be in the service | string | `"1"` | no |
| stage | stage name | string | n/a | yes |
| tags |  | map | `<map>` | no |
| url | url for the alb listener | string | n/a | yes |
| vpc\_id | vpc id - used in target group, security group etc | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecr\_repository |  |




## Resources
| Resources |
| --------- |
| container definition |
| task definition |
| service |
| target group + healtcheck |
| task execution role |
| ecr |
| cloudwatch log group |
| iam policy - write to logs |
| iam policy - pull from ecr |
| attachment of policies to the role - pass data / roles? |
| security group |
| listener_rule |
