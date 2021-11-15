provider "aws" {
  region = "us-east-2"
}

locals {
  user-data = templatefile("${path.module}/userdata.yaml", {
    private-vpc = data.aws_vpc.prod.cidr_block
    public-vpc  = data.aws_vpc.shared.cidr_block
    nonprod-vpc = data.aws_vpc.nonprod.cidr_block
  })
  tags = {
    Project = "eks-lab"
  }
}

data "aws_vpc" "prod" {
  tags = {
    Name = "prod"
  }
}

data "aws_vpc" "shared" {
  tags = {
    Name = "shared"
  }

}

data "aws_vpc" "nonprod" {
  tags = {
    Name = "nonprod"
  }

}

data "aws_subnet_ids" "public-subnets" {
  vpc_id = data.aws_vpc.shared.id
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.prod.id
}

data "aws_security_group" "proxy-sg" {
  name   = "proxy_inbound"
  vpc_id = data.aws_vpc.shared.id
}

data "aws_security_group" "client-sg" {
  name   = "client-sg"
  vpc_id = data.aws_vpc.prod.id
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    # values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    # values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu*-amd64-server-*"]
    # values = ["Deep Learning Base AMI (Ubuntu 18.04) Version 36.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }


  # owners = ["amazon"]
  owners = ["099720109477"] # Canonical
}


resource "aws_launch_template" "tinyproxy" {
  # for_each = toset(var.spot_instances)
  name = "Tinyproxy_LaunchTemplate"

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = 20
    }
  }

  disable_api_termination = false

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  image_id = data.aws_ami.ubuntu.id

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t3.medium"

  key_name  = "ubuntu"
  user_data = base64encode(local.user-data)

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.proxy-sg.id]
    subnet_id                   = tolist(data.aws_subnet_ids.public-subnets.ids)[0]
    private_ip_address          = var.proxy-ip

  }

  # placement {
  #   availability_zone = var.ec2-availability-zone
  # }

  # vpc_security_group_ids = [data.terraform_remote_state.network.outputs.proxy-sg-id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.tags,
      {
        Name = "TinyProxy"
    })
  }
  tag_specifications {
    resource_type = "volume"

    tags = local.tags
  }
  tag_specifications {
    resource_type = "spot-instances-request"

    tags = local.tags
  }

  tags = local.tags


}


resource "aws_launch_template" "private-ec2" {
  # for_each = toset(var.on_demand_instances)
  name = "Private_EC2_LaunchTemplate"

  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      volume_type           = "gp2"
      volume_size           = 20
    }
  }

  disable_api_termination = false

  ebs_optimized = true

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  image_id = data.aws_ami.ubuntu.id

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t3.micro"

  key_name = "ubuntu"

  network_interfaces {
    # associate_public_ip_address = true
    security_groups = [data.aws_security_group.client-sg.id]
    subnet_id       = tolist(data.aws_subnet_ids.private-subnets.ids)[0]
  }

  # placement {
  #   availability_zone = var.ec2_availability_zone

  # }

  # vpc_security_group_ids = [data.terraform_remote_state.network.outputs.client-sg-id]

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }
  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "spot-instances-request"

    tags = local.tags
  }

  tags = local.tags


}

resource "aws_spot_instance_request" "tinyproxy" {
  # spot settings
  # spot_price           = var.spot-price
  spot_type            = "one-time"
  wait_for_fulfillment = true
  # valid_until          = timeadd(timestamp(), "10m")
  # ec2 instance
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = true
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  instance_type               = var.instance-type
  key_name                    = var.ec2-key
  private_ip                  = var.proxy-ip
  subnet_id                   = tolist(data.aws_subnet_ids.public-subnets.ids)[0]
  user_data_base64            = base64encode(local.user-data)
  vpc_security_group_ids      = [data.aws_security_group.proxy-sg.id]

  root_block_device {
    encrypted             = true
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }

  tags = local.tags
}

resource "aws_ec2_tag" "ec2_tag" {
  for_each    = merge(local.tags, { Name = "TinyProxy" })
  resource_id = aws_spot_instance_request.tinyproxy.spot_instance_id
  key         = each.key
  value       = each.value
}

data "aws_ebs_volume" "ebs_volume" {
  most_recent = true

  filter {
    name   = "attachment.instance-id"
    values = [aws_spot_instance_request.tinyproxy.spot_instance_id]
  }
}

resource "aws_ec2_tag" "volume_tag" {
  for_each    = local.tags
  resource_id = data.aws_ebs_volume.ebs_volume.id
  key         = each.key
  value       = each.value
}