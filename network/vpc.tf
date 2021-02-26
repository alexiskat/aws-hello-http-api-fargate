
resource "aws_vpc" "main" {
  cidr_block           = module.config.entries.network.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}main-vpc"
    },
  )
}

resource "aws_subnet" "public_sub_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = module.config.entries.network.public_sub_1a_zone_id
  cidr_block        = module.config.entries.network.public_sub_1a_cidr

  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}public-sub-1a"
    },
  )
}

resource "aws_subnet" "public_sub_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = module.config.entries.network.public_sub_1b_zone_id
  cidr_block        = module.config.entries.network.public_sub_1b_cidr

  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}public-sub-1b"
    },
  )
}

resource "aws_subnet" "private_sub_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = module.config.entries.network.private_sub_1a_zone_id
  cidr_block        = module.config.entries.network.private_sub_1a_cidr

  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}private-sub-1a"
    },
  )
}

resource "aws_subnet" "private_sub_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = module.config.entries.network.private_sub_1b_zone_id
  cidr_block        = module.config.entries.network.private_sub_1b_cidr

  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}private-sub-1b"
    },
  )
}