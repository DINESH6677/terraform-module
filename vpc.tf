resource "aws_vpc" "main" {
  cidr_block       = var.Vpc_CIDRBLOCK
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tester_tags,
    local.common_tags,
    {
      Name = local.common_name_suffix
    }
  )
}

resource "aws_internet_gateway" "vpc-gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.vpc-gw-tags,
    local.common_tags,
    {
      Name = local.common_name_suffix
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.vpc-public-route-tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.vpc-private-route-tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-private"
    }
  )
}

resource "aws_route_table" "database_routetable" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.vpc-database-route-tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-database"
    }
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc-gw.id
  
}

resource "aws_eip" "EIP-Nat" {
  domain   = "vpc"
  tags = merge(
    var.vpc-eip-tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-eip-nat"
    }
  )
}

resource "aws_nat_gateway" "Nat" {
  allocation_id = aws_eip.EIP-Nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.vpc-nat-tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-nat"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpc-gw]
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.Nat.id
  
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database_routetable.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.Nat.id
  
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database_routetable.id
}