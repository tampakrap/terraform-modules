variable "project" {}

variable "stage" {}

variable "app" {}

variable "tags" {
  type    = "map"
  default = {}
}

variable "subnets" {
  type = "list"
}

variable "automatic_failover_enabled" {
  default = false
}

variable "desired_clusters" {
  default = "1"
}

variable "instance_type" {
  default = "cache.t2.micro"
}

variable "parameter_group" {
  default = "default.redis5.0"
}

variable "security_group_ids" {
  type = "list"
}

variable "port" {
  default = "6379"
}

variable "maintenance_window" {
  default = "wed:03:00-wed:04:00"
}
