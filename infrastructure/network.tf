resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "EKS_VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "example" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.example.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.eks.id

  tags = {
    "kubernetes.io/cluster/${aws_eks_cluster.example.name}" = "shared"
  }
}