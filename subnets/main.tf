resource "aws_subnet" "main" {
  count=length(var.cidr_block)
  vpc_id     = var.vpc_id
  cidr_block = element("cidr_block",count.index)
  availability_zone = element(var.az,count.index )

  tags = {
    Name = "${var.env}-${var.subnet_name}-subnet"
  }
}