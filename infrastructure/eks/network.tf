data "aws_vpc" "prod" {
  tags = {
    Name = "prod"
  }
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.prod.id
}

