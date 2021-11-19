provider "aws" {
  region = "us-east-2"
}

data "aws_region" "current" {}


data "aws_vpc" "nonprod" {
  tags = {
    Name = "nonprod"
  }

}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.nonprod.id
}

resource "aws_security_group" "interface-sg" {
  name        = "interface-sg"
  description = "Allow all VPC endpoint sg"
  vpc_id      = data.aws_vpc.nonprod.id

  ingress {
    description = "Inbound https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.nonprod.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_shuffle" "subnets" {
  for_each     = toset(var.interface-endpoint-services)
  input        = tolist(data.aws_subnet_ids.private-subnets.ids)
  result_count = 1
}

resource "aws_vpc_endpoint" "ec2" {
  for_each          = random_shuffle.subnets
  vpc_id            = data.aws_vpc.nonprod.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.interface-sg.id,
  ]
  subnet_ids = each.value.result

  private_dns_enabled = true
}

