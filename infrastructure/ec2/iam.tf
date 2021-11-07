resource "aws_iam_instance_profile" "profile" {
  name = "client_role"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "client_role"
  path = "/org/app/client/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cw-logs" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.role.name

}

resource "aws_iam_role_policy_attachment" "eks-read" {
  policy_arn = aws_iam_policy.eks-read.arn
  role       = aws_iam_role.role.name

}



data "aws_iam_policy_document" "eks-read" {
  statement {
    actions   = ["eks:DescribeCluster"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eks-read" {
  name   = "eks-read"
  path   = "/org/app/eks/"
  policy = data.aws_iam_policy_document.eks-read.json
}

