variable "cluster_name" {}
variable "service_name" {}
variable "task_definition_name" {}
variable "image_url" {}
variable "container_port" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }

