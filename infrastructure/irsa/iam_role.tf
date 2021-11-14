data "aws_caller_identity" "current" {}

locals {
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/org/boundaries/admin/org-admin-permission-boundary"
}

resource "aws_iam_role" "app-role" {
  name                 = "app-role"
  path                 = "/org/app/eks/"
  permissions_boundary = local.permissions_boundary

  assume_role_policy = templatefile("${path.module}/assumerole_policy.json", {
    OIDC_PROVIDER  = replace(aws_iam_openid_connect_provider.eks-oidc.url, "https://", "")
    oidc-arn       = aws_iam_openid_connect_provider.eks-oidc.arn
    namespace      = "default"
    serviceaccount = "app"
  })
}