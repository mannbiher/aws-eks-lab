provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}



locals {
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/org/boundaries/admin/org-admin-permission-boundary"
}

resource "aws_iam_role" "eks-cluster-role" {
  name                 = "eks-cluster-role"
  path                 = "/org/app/eks/"
  permissions_boundary = local.permissions_boundary

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}


resource "aws_cloudwatch_log_group" "devops-eks-cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

}

resource "aws_eks_cluster" "devops-eks-cluster" {
  name                      = var.cluster_name
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  depends_on = [
    aws_cloudwatch_log_group.devops-eks-cluster,
    aws_iam_role_policy_attachment.amazon-eks-cluster-policy
  ]
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids              = data.aws_subnet_ids.private-subnets.ids
    endpoint_public_access  = true
    endpoint_private_access = true
    security_group_ids      = [var.node_sg]
    public_access_cidrs     = ["${data.http.my_ip.body}/32"]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

}



