provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {}

resource "aws_vpc" "prod" {
  cidr_block           = "10.254.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "prod"
  }
}

resource "aws_vpc" "nonprod" {
  cidr_block           = "10.253.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "nonprod"
  }
}



resource "aws_vpc" "shared" {
  cidr_block           = "10.255.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "shared"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_names = data.aws_availability_zones.available.names
}

# only private subnets in prod
resource "aws_subnet" "prod-private" {
  for_each          = { for idx, az_name in local.az_names : idx => az_name }
  vpc_id            = aws_vpc.prod.id
  cidr_block        = cidrsubnet(aws_vpc.prod.cidr_block, 4, each.key)
  availability_zone = local.az_names[each.key]
  tags = {
    Name = "private-${local.az_names[each.key]}"
  }
}


# only private subnets in prod
resource "aws_subnet" "nonprod-private" {
  for_each          = { for idx, az_name in local.az_names : idx => az_name }
  vpc_id            = aws_vpc.nonprod.id
  cidr_block        = cidrsubnet(aws_vpc.nonprod.cidr_block, 4, each.key)
  availability_zone = local.az_names[each.key]
  tags = {
    Name = "private-${local.az_names[each.key]}"
  }
}




# only public subnets in shared
resource "aws_subnet" "shared-public" {
  for_each                = { for idx, az_name in local.az_names : idx => az_name }
  vpc_id                  = aws_vpc.shared.id
  cidr_block              = cidrsubnet(aws_vpc.shared.cidr_block, 4, each.key)
  availability_zone       = local.az_names[each.key]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-${local.az_names[each.key]}"
  }
}


resource "aws_vpc_peering_connection" "shared" {
  vpc_id      = aws_vpc.prod.id
  peer_vpc_id = aws_vpc.shared.id
  auto_accept = true
}

resource "aws_vpc_peering_connection" "nonprod-shared" {
  vpc_id      = aws_vpc.nonprod.id
  peer_vpc_id = aws_vpc.shared.id
  auto_accept = true
}

resource "aws_vpc_peering_connection_options" "shared" {
  vpc_peering_connection_id = aws_vpc_peering_connection.shared.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "nonprod-shared" {
  vpc_peering_connection_id = aws_vpc_peering_connection.nonprod-shared.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.shared.id

  tags = {
    Name = "shared"
  }
}



resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block                = aws_vpc.shared.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.shared.id
  }


  tags = {
    Name = "prod"
  }
}

resource "aws_route_table" "nonprod" {
  vpc_id = aws_vpc.nonprod.id

  route {
    cidr_block                = aws_vpc.shared.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.nonprod-shared.id
  }


  tags = {
    Name = "nonprod"
  }
}


resource "aws_route_table" "shared" {
  vpc_id = aws_vpc.shared.id

  route {
    cidr_block                = aws_vpc.prod.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.shared.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "shared"
  }
}

resource "aws_main_route_table_association" "prod" {
  vpc_id         = aws_vpc.prod.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_main_route_table_association" "nonprod-shared" {
  vpc_id         = aws_vpc.nonprod.id
  route_table_id = aws_route_table.nonprod.id
}

resource "aws_main_route_table_association" "shared" {
  vpc_id         = aws_vpc.shared.id
  route_table_id = aws_route_table.shared.id
}

 