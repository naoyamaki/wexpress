data "aws_caller_identity" "self" {}
variable "environment" {}
variable "aws-region" {}
variable "domain-name" {}
variable "service-name" {}
variable "vpc-cider" {}
variable "pub-1c-cider" {}
variable "pub-1d-cider" {}
variable "pri-1c-cider" {}
variable "pri-1d-cider" {}
variable "db-1c-cider" {}
variable "db-1d-cider" {}
variable "aurora-count" {}
variable "aurora-min-capacity" {}
variable "aurora-max-capacity" {}
variable "db-user" {}
variable "db-password" {}
