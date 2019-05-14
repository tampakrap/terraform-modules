## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app |  | string | n/a | yes |
| automatic\_failover\_enabled |  | string | `"false"` | no |
| desired\_clusters |  | string | `"1"` | no |
| instance\_type |  | string | `"cache.t2.micro"` | no |
| maintenance\_window |  | string | `"wed:03:00-wed:04:00"` | no |
| parameter\_group |  | string | `"default.redis5.0"` | no |
| port |  | string | `"6379"` | no |
| project |  | string | n/a | yes |
| security\_group\_ids |  | list | n/a | yes |
| stage |  | string | n/a | yes |
| subnets |  | list | n/a | yes |
| tags |  | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Endpoint URL address |
| id | Redis cluster ID |
| port | Redis port |

