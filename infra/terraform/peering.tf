resource "aws_vpc_peering_connection" "us_eu" {

  vpc_id      = module.us_vpc.vpc_id
  peer_vpc_id = module.eu_vpc.vpc_id

  peer_region = "eu-west-1"

  auto_accept = false

  tags = {
    Name = "us-to-eu-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "eu_accept" {

  provider = aws.eu

  vpc_peering_connection_id = aws_vpc_peering_connection.us_eu.id

  auto_accept = true

  tags = {
    Name = "eu-accept-us-peering"
  }
}

resource "aws_vpc_peering_connection" "us_apac" {

  vpc_id      = module.us_vpc.vpc_id
  peer_vpc_id = module.apac_vpc.vpc_id

  peer_region = "ap-south-1"

  auto_accept = false

  tags = {
    Name = "us-to-apac-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "apac_accept" {

  provider = aws.apac

  vpc_peering_connection_id = aws_vpc_peering_connection.us_apac.id

  auto_accept = true

  tags = {
    Name = "apac-accept-us-peering"
  }
}

#
# Routes : US <-> EU
#

resource "aws_route" "us_to_eu" {

  route_table_id = module.us_vpc.private_route_table_id

  destination_cidr_block = "10.1.0.0/16"

  vpc_peering_connection_id = aws_vpc_peering_connection.us_eu.id
}

resource "aws_route" "eu_to_us" {

  provider = aws.eu

  route_table_id = module.eu_vpc.private_route_table_id

  destination_cidr_block = "10.0.0.0/16"

  vpc_peering_connection_id = aws_vpc_peering_connection.us_eu.id
}

#
# Routes : US <-> APAC
#

resource "aws_route" "us_to_apac" {

  route_table_id = module.us_vpc.private_route_table_id

  destination_cidr_block = "10.2.0.0/16"

  vpc_peering_connection_id = aws_vpc_peering_connection.us_apac.id
}

resource "aws_route" "apac_to_us" {

  provider = aws.apac

  route_table_id = module.apac_vpc.private_route_table_id

  destination_cidr_block = "10.0.0.0/16"

  vpc_peering_connection_id = aws_vpc_peering_connection.us_apac.id
}