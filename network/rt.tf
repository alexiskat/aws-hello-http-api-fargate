
#
# Public Subnet 1a routing
#
resource "aws_route_table" "rt_pub_sub1a" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}rt-public-sub-1a"
    },
  )
}

resource "aws_route_table_association" "rt_for_pub_sub1a" {
  subnet_id      = aws_subnet.public_sub_1a.id
  route_table_id = aws_route_table.rt_pub_sub1a.id
}

resource "aws_route" "rt_pub_sub1a_internet" {
  route_table_id         = aws_route_table.rt_pub_sub1a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

#
# Public Subnet 1b routing
#
resource "aws_route_table" "rt_pub_sub1b" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}rt-public-sub-1b"
    },
  )
}

resource "aws_route_table_association" "rt_for_pub_sub1b" {
  subnet_id      = aws_subnet.public_sub_1b.id
  route_table_id = aws_route_table.rt_pub_sub1b.id
}

resource "aws_route" "rt_pub_sub1b_internet" {
  route_table_id         = aws_route_table.rt_pub_sub1b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

#
# Private Subnet 1a routing
#
resource "aws_route_table" "rt_pri_sub1a" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}rt-private-sub-1a"
    },
  )
}

resource "aws_route_table_association" "rt_for_pri_sub1a" {
  subnet_id      = aws_subnet.private_sub_1a.id
  route_table_id = aws_route_table.rt_pri_sub1a.id
}

resource "aws_route" "rt_pri_sub1a_internet" {
  route_table_id         = aws_route_table.rt_pri_sub1a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_public_sub_1a.id
}

#
# Private Subnet 1b routing
#
resource "aws_route_table" "rt_pri_sub1b" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}rt-private-sub-1b"
    },
  )
}

resource "aws_route_table_association" "rt_for_pri_sub1b" {
  subnet_id      = aws_subnet.private_sub_1b.id
  route_table_id = aws_route_table.rt_pri_sub1b.id
}

resource "aws_route" "rt_pri_sub1b_internet" {
  route_table_id         = aws_route_table.rt_pri_sub1b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway_public_sub_1b.id
}