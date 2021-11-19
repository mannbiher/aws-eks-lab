terraform {
  backend "s3" {
    bucket  = "m-terraform-state"
    key     = "eks-vpc-endpoints"
    region  = "us-east-1"
    encrypt = true
  }
}