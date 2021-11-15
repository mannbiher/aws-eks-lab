resource "aws_security_group" "proxy-inbound" {
  name        = "proxy_inbound"
  description = "Allow inbound proxy traffic"
  vpc_id      = aws_vpc.shared.id

  ingress {
    description = "Inbound proxy"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.prod.cidr_block]

  }

  ingress {
    description = "Inbound ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.http.my_ip.body}/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "client-sg" {
  name        = "client-sg"
  description = "Allow inbound from bastion"
  vpc_id      = aws_vpc.prod.id



  ingress {
    description = "Inbound ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.shared.cidr_block]
  }

  ingress {
    description = "Inbound https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.shared.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}