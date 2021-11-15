

provider "kubernetes" {
  host                   = aws_eks_cluster.devops-eks-cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.devops-eks-cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}


locals {
  worker-roles = [
    for rolename in [aws_iam_role.worker-role.name] : {
      "rolearn"  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${rolename}"
      "username" = "system:node:{{EC2PrivateDNSName}}"
      "groups"   = ["system:bootstrappers", "system:nodes"]
    }
  ]
  admin-roles = [for rolename in var.kube-admin-rolenames : {
    "rolearn"  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${rolename}"
    "username" = "admin:{{SessionName}}"
    "groups"   = ["system:masters"]

    }
  ]


}

locals {
  map-roles = concat(local.worker-roles, local.admin-roles)
}

resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.map-roles)
  }

}


resource "kubernetes_config_map" "proxy-environment" {
  metadata {
    name      = "proxy-environment-variables"
    namespace = "kube-system"
  }

  data = {
    "http_proxy"  = "http://${var.proxy}"
    "HTTP_PROXY"  = "http://${var.proxy}"
    "https_proxy" = "http://${var.proxy}"
    "HTTPS_PROXY" = "http://${var.proxy}"
    "no_proxy"    = "172.20.0.0/16,10.0.0.0/8,localhost,127.0.0.1,169.254.169.254,.internal,.s3.${data.aws_region.current.name}.amazonaws.com,${local.cluster-host}"
    "NO_PROXY"    = "172.20.0.0/16,10.0.0.0/8,localhost,127.0.0.1,169.254.169.254,.internal,.s3.${data.aws_region.current.name}.amazonaws.com,${local.cluster-host}"
  }

  provisioner "local-exec" {
    command = "./proxy_setup.sh ${aws_eks_cluster.devops-eks-cluster.id} ${split(":", aws_eks_cluster.devops-eks-cluster.arn)[3]}"
  }

}
