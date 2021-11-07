variable "instance-type" {
  description = "EC2 instance type"
}

variable "ec2-key" {
  description = "EC2 key pair"
}

variable "spot-price" {
  description = "EC2 spot price"
}

variable "ec2-iam-profile" {
  description = "EC2 IAM profile"
}

variable "ec2-security-group" {

}

variable "ec2-availability-zone" {

}


variable "ami-id" {
  description = "Preconfigured image for FLANNEL data and code"
}


variable "spot-instances" {
  type = list(string)
  default = [
    "t3.micro",
    "t3.medium",
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "m5.large",
    "m5.xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
    "p2.xlarge",
    "p2.8xlarge",
    "p3.2xlarge",
    "p3.8xlarge"
  ]
  description = "Allowed spot instances"
}

