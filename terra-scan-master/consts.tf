data "aws_caller_identity" "current" {}

variable "region" {
  default = "eu-west-2"
}

variable "profile" {
  default = "default"
}

variable "environment" {
  default = "dev"
}

locals {
  resource_prefix = {
    value = "${data.aws_caller_identity.current.account_id}-${var.environment}"
  }
}

