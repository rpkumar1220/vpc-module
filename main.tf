###Creating VPC####
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support = true

  tags = {
    Name ="${var.env}-vpc"
  }
}

######Calling Subnets module#######
module "subnets" {
  source="./subnets"
  for_each = var.subnets
  vpc_id=aws_vpc.main.id
  cidr_block=each.value["cidr_block"]
  subnet_name = each.key
  az=var.az
  env = var.env
}


####Creating Internet Gateway######
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

###Creating Internet Gateway####
resource "aws_route" "igw_route" {
  route_table_id            = module.subnets["public"].route_table_ids
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw
}


####attaching internet gateway to VPC#####
resource "aws_internet_gateway_attachment" "igw-attach" {
  internet_gateway_id = aws_internet_gateway.igw.id
  vpc_id              = aws_vpc.main.id
}

###Creating Elastic IP########
resource "aws_eip" "eip" {
  domain   = "vpc"
}

####Creating NAT gateway and attaching elastic IP and public subnet####
resource "aws_nat_gateway" "ngw" {

  allocation_id = aws_eip.eip.id
  subnet_id     = lookup(lookup(module.subnets,"public",null),"subnet_ids",null)[0]

  tags = {
    Name = "${var.env}-public_ngw"
  }
}

###Creating Nat route for all private subnets########
resource "aws_route" "ngw_route" {
  count = length(local.private_subnets_route_ids)
  route_table_id            = element(local.private_subnets_route_ids,count.index)
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.ngw.id
}

###Creating VPC peering connection between DEV VPC and default VPC####
resource "aws_vpc_peering_connection" "peer" {
    peer_vpc_id   = aws_vpc.main.id
  vpc_id        = var.default_vpc_id
  auto_accept   = true

  tags = {
    Name = "default vpc to ${var.env}"
  }
}


####Creating peer routes for all subnets###
resource "aws_route" "peer_route" {
  count = length(local.all_subnets_route_ids)
  route_table_id            = element(local.all_subnets_route_ids,count.index)
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

###Creating peer route for default vpc####
resource "aws_route" "default_route" {
  route_table_id            = var.default_vpc_rt
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
