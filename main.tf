resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support = true

  tags = {
    Name ="${var.env}-vpc"
  }
}

module "subnets" {
  source="./subnets"
  for_each = var.subnets
  vpc_id=aws_vpc.main.id
  cidr_block=each.value["cidr_block"]
  subnet_name = each.key
  env = var.env


}