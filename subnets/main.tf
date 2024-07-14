resource "aws_subnet" "main" {
  vpc_id     = var.vpc_id
  for_each = var.subnet_name
  cidr_block = each.value["cidr_block"]


  tags = {
    Name = "${var.env}-${var.subnet_name}-subnet"
  }
}