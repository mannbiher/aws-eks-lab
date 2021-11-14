terraform {
  backend "s3" {
    bucket  = "m-terraform-state"
    key     = "eks-state-irsa"
    region  = "us-east-1"
    encrypt = true
  }
}