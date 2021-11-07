resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.prod.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}


resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.prod.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}