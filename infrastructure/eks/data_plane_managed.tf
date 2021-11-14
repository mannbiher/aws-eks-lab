
locals {
  cluster-host = trimprefix(aws_eks_cluster.devops-eks-cluster.endpoint, "https://")
}

locals {
  user-data = templatefile("${path.module}/userdata.sh", {
    proxy        = var.proxy
    vpc-cidr     = "10.0.0.0/8"
    region       = data.aws_region.current.name
    cluster-host = local.cluster-host
  })
  tags = {
    Project = "eks-lab"
  }
}

resource "aws_iam_role" "worker-role" {
  name                 = "eks-worker-role"
  path                 = "/org/app/eks/"
  permissions_boundary = local.permissions_boundary

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "amazoneks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "amazoneks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-role.name
}

resource "aws_iam_role_policy_attachment" "amazon-ecr-readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-role.name
}


resource "aws_eks_node_group" "managed" {
  cluster_name    = aws_eks_cluster.devops-eks-cluster.name
  node_group_name = "ec2-managed"
  node_role_arn   = aws_iam_role.worker-role.arn
  subnet_ids      = data.aws_subnet_ids.private-subnets.ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  capacity_type = "SPOT"

  launch_template {
    name    = aws_launch_template.eks-devops.name
    version = aws_launch_template.eks-devops.latest_version
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.amazoneks-worker-node-policy,
    aws_iam_role_policy_attachment.amazon-ecr-readonly,
    aws_iam_role_policy_attachment.amazoneks-cni-policy,
    kubernetes_config_map.aws-auth
  ]
}




resource "aws_launch_template" "eks-devops" {
  name                   = "eks-devops"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 50
      volume_type           = "gp3"
    }
  }
  instance_type = "t3.medium"

  #   instance_market_options {
  #     market_type = "spot"
  #   }

  vpc_security_group_ids = [
    var.node_sg,
    aws_eks_cluster.devops-eks-cluster.vpc_config[0].cluster_security_group_id
  ]
  key_name = "ubuntu"

  user_data = base64encode(local.user-data)

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