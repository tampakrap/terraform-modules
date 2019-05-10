## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| adjustment\_type | Options: ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity | string | `"ChangeInCapacity"` | no |
| alarm\_actions\_enabled |  | string | `"true"` | no |
| alarm\_period | The period in seconds over which the specified statistic is applied. | string | `"120"` | no |
| alarm\_threshold\_down | The value against which the specified statistic is compared. | string | `"45"` | no |
| alarm\_threshold\_up | The value against which the specified statistic is compared. | string | `"100"` | no |
| cluster\_name | Required: | string | n/a | yes |
| default\_cooldown |  | string | `"30"` | no |
| ecsInstanceRoleAssumeRolePolicy |  | string | `"{\n  \"Version\": \"2008-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ec2.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"` | no |
| ecsInstancerolePolicy |  | string | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"ecs:CreateCluster\",\n        \"ecs:DeregisterContainerInstance\",\n        \"ecs:DiscoverPollEndpoint\",\n        \"ecs:Poll\",\n        \"ecs:RegisterContainerInstance\",\n        \"ecs:StartTelemetrySession\",\n        \"ecs:Submit*\",\n        \"ecr:GetAuthorizationToken\",\n        \"ecr:BatchCheckLayerAvailability\",\n        \"ecr:GetDownloadUrlForLayer\",\n        \"ecr:BatchGetImage\",\n        \"logs:CreateLogStream\",\n        \"logs:PutLogEvents\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"` | no |
| ecsServiceRoleAssumeRolePolicy |  | string | `"{\n  \"Version\": \"2008-10-17\",\n  \"Statement\": [\n    {\n      \"Sid\": \"\",\n      \"Effect\": \"Allow\",\n      \"Principal\": {\n        \"Service\": \"ecs.amazonaws.com\"\n      },\n      \"Action\": \"sts:AssumeRole\"\n    }\n  ]\n}\n"` | no |
| ecsServiceRolePolicy |  | string | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"ec2:AuthorizeSecurityGroupIngress\",\n        \"ec2:Describe*\",\n        \"elasticloadbalancing:DeregisterInstancesFromLoadBalancer\",\n        \"elasticloadbalancing:DeregisterTargets\",\n        \"elasticloadbalancing:Describe*\",\n        \"elasticloadbalancing:RegisterInstancesWithLoadBalancer\",\n        \"elasticloadbalancing:RegisterTargets\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"` | no |
| evaluation\_periods | The number of periods over which data is compared to the specified threshold. | string | `"2"` | no |
| health\_check\_grace\_period |  | string | `"300"` | no |
| health\_check\_type |  | string | `"EC2"` | no |
| instance\_type | See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes | string | `"t2.micro"` | no |
| max\_size |  | string | `"5"` | no |
| min\_size |  | string | `"1"` | no |
| policy\_cooldown | The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start. | string | `"300"` | no |
| protect\_from\_scale\_in |  | string | `"false"` | no |
| root\_volume\_size |  | string | `"8"` | no |
| scaling\_adjustment\_down | How many instances to scale down by when triggered | string | `"-1"` | no |
| scaling\_adjustment\_up | How many instances to scale up by when triggered | string | `"1"` | no |
| scaling\_metric\_name | Options: CPUReservation or MemoryReservation | string | `"CPUReservation"` | no |
| security\_groups | List of security groups to place instances into | list | n/a | yes |
| ssh\_key\_name | Name of SSH key pair to use as default (ec2-user) user key | string | `""` | no |
| subnet\_ids | List of VPC Subnet IDs to place instances into | list | n/a | yes |
| tags | List of maps with keys: 'key', 'value', and 'propagate_at_launch' | list | `<list>` | no |
| termination\_policies | The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | list | `<list>` | no |
| user\_data | Bash code for inclusion as user_data on instances. By default contains minimum for registering with ECS cluster | string | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg\_arn |  |
| asg\_id |  |
| asg\_launch\_configuration |  |
| ecsInstanceRole\_arn |  |
| ecsServiceRole\_arn |  |
| ecs\_ami\_id |  |
| ecs\_cluster\_id |  |
| ecs\_cluster\_name |  |
| ecs\_instance\_profile\_id |  |

