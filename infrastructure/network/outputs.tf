output "prod-vpc-id" {
  value = aws_vpc.prod.id
}

output "shared-vpc-id" {
  value = aws_vpc.shared.id
}

output "nonprod-vpc-id" {
  value = aws_vpc.nonprod.id
}

output "proxy-sg-id" {
  value = aws_security_group.proxy-inbound.id
}


output "client-sg-id" {
  value = aws_security_group.client-sg.id
}