provider "aws" {
  region = "us-east-2"
}

variable "cluster-name" {
  default = "devops-eks-cluster"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}

data "tls_certificate" "cluster-issuer" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster-issuer.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}