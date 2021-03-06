variable "jumpbox_ip" {
  default = "10.0.1.11"
}

variable "default_gw_ip" {
  default = "10.0.1.1"
}

variable "default_route_table_id" {}
variable "vpc_id" {}
variable "environment" {}

variable "region" {
  default = "eu-west-1"
}

variable "az1" {
  default = "eu-west-1a"
}

variable "az2" {
  default = "eu-west-1b"
}

variable "parent_dns_zone" {}

variable "ingress_whitelist" {
  "type" = "list"
}

variable "state_bucket_id" {}

variable "s3_kms_key_arn" {}

variable "concourse_security_group_id" {}
