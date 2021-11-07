variable "cluster_name" {
  default = "devops-eks-cluster"
  type    = string
}

variable "cluster_subnets" {
  type = list(string)
}

variable "node_sg" {
  type = string
}

variable "proxy" {
}