variable "cluster_name" {
  default = "example"
  type    = string
}

variable "cluster_subnets" {
  type = list(string)
}