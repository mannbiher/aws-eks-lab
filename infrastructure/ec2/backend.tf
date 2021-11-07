terraform {
  backend "s3" {
    bucket  = "m-terraform-state"
    key     = "eks-proxy-ec2"
    region  = "us-east-1"
    encrypt = true
  }
}