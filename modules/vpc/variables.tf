# modules/vpc/variables.tf
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "simple-prod-vpc"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  type    = string
  default = "" # e.g. "ap-south-1a" - root should pass this (or leave empty to let provider choose)
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
