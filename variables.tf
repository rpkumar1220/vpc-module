variable "env" {}
variable "tags" {}
variable "cidr_block" {}
variable "subnets" {}
variable "az" { default = ["us-east-1a","us-east-1b"] }
variable "default_vpc_rt" {}
variable "default_vpc_id" {}