output "endpoint" {
  value = aws_eks_cluster.devops-eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.devops-eks-cluster.certificate_authority[0].data
}