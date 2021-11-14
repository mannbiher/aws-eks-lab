provider "aws" {
  region = "us-east-2"
}

variable "cluster-name" {
  default = "devops-eks-cluster"
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}



locals {
  cluster-endpoint = data.aws_eks_cluster.cluster.endpoint
  cluster-ca-cert  = data.aws_eks_cluster.cluster.certificate_authority[0].data
}

provider "kubernetes" {
  host                   = local.cluster-endpoint
  cluster_ca_certificate = base64decode(local.cluster-ca-cert)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
    command     = "aws"
  }
}


provider "helm" {
  kubernetes {
    host                   = local.cluster-endpoint
    cluster_ca_certificate = base64decode(local.cluster-ca-cert)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}