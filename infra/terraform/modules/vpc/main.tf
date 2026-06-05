resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.region_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.region_name}-igw"
  }
}

resource "aws_subnet" "public_1" {

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_1
  availability_zone       = "${var.region_name}a"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.region_name}-public-1"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_2" {

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_2
  availability_zone       = "${var.region_name}b"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.region_name}-public-2"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_1" {

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_1
  availability_zone = "${var.region_name}a"

  tags = {
    Name                                        = "${var.region_name}-private-1"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_2" {

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_2
  availability_zone = "${var.region_name}b"

  tags = {
    Name                                        = "${var.region_name}-private-2"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "${var.region_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name = "${var.region_name}-nat"
  }
}

#
# Route Tables
#

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.region_name}-public-rt"
  }
}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.region_name}-private-rt"
  }
}

#
# Routes
#

resource "aws_route" "public_internet" {

  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = aws_internet_gateway.this.id
}

resource "aws_route" "private_nat" {

  route_table_id = aws_route_table.private.id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this.id
}

#
# Route Table Associations
#

resource "aws_route_table_association" "public_1" {

  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {

  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {

  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {

  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}