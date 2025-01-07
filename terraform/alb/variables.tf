variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "listener_port" {}
variable "target_group_port" {}
variable "target_group_protocol" {}
variable "certificate_arn" {}
variable "ecs_service_arn" {}

