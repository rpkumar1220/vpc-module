resource "aws_subnet" "main" {
  count=length(var.cidr_block)
  vpc_id     = var.vpc_id
  cidr_block = element(var.cidr_block,count.index)
  availability_zone = element(var.az,count.index)

  tags = {
    Name = "${var.env}-${var.subnet_name}-subnet"
  }
}


###Creating Route table for each subnet#####
resource "aws_route_table" "rt_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env}-${var.subnet_name}-rt"
  }
}

####Associating route table to subnet####
resource "aws_route_table_association" "rt_ass" {
  count = length(aws_subnet.main.*.id)
  subnet_id      = element(aws_subnet.main.*.id,count.index)
  route_table_id = aws_route_table.rt_table.id
}