
resource "aws_eip" "nat_gateway_1a_pub_1_eip" {
  vpc = true
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}eip-nat-pub-sub-1a"
    },
  )
}

resource "aws_nat_gateway" "nat_gateway_public_sub_1a" {
  allocation_id = aws_eip.nat_gateway_1a_pub_1_eip.id
  subnet_id     = aws_subnet.public_sub_1a.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}nat-gw-pub-sub-1a"
    },
  )
}

resource "aws_eip" "nat_gateway_1b_pub_1_eip" {
  vpc = true
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}eip-nat-pub-sub-1b"
    },
  )
}

resource "aws_nat_gateway" "nat_gateway_public_sub_1b" {
  allocation_id = aws_eip.nat_gateway_1b_pub_1_eip.id
  subnet_id     = aws_subnet.public_sub_1b.id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}nat-gw-pub-sub-1b"
    },
  )
}