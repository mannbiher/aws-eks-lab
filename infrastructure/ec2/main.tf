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
  id = data.terraform_remote_state.network.outputs.prod-vpc-id
}

data "aws_vpc" "shared" {
  id = data.terraform_remote_state.network.outputs.shared-vpc-id

}

data "aws_vpc" "nonprod" {
  id = data.terraform_remote_state.network.outputs.nonprod-vpc-id

}

data "aws_subnet_ids" "public-subnets" {
  vpc_id = data.aws_vpc.shared.id
}

data "aws_subnet_ids" "private-subnets" {
  vpc_id = data.aws_vpc.prod.id
}


data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "m-terraform-state"
    key    = "eks-state-network"
    region = "us-east-1"

  }
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
    security_groups             = [data.terraform_remote_state.network.outputs.proxy-sg-id]
    subnet_id                   = tolist(data.aws_subnet_ids.public-subnets.ids)[0]

  }

  # placement {
  #   availability_zone = var.ec2-availability-zone
  # }

  # vpc_security_group_ids = [data.terraform_remote_state.network.outputs.proxy-sg-id]

  tag_specifications {
    resource_type = "instance"

    tags = local.tags
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
    security_groups = [data.terraform_remote_state.network.outputs.client-sg-id]
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