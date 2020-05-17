data "external" "thumbprint" {
  program = ["${path.module}/bin/get_thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = flatten(concat(aws_eks_cluster.this.identity[*].oidc.0.issuer, [""]))[0]
}

data "aws_iam_policy_document" "oidc-assume-role" {
  statement {
    sid = "OIDC"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-alb-ingress-controller"
      ]
    }

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
      ]
    }
  }
}
