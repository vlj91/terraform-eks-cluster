variable "fargate_profiles" {
  type    = list(string)
  default = []
}

data "aws_iam_policy_document" "fargate-profile-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "fargate-profile" {
  name               = "${var.cluster_name}-eks-fargate"
  assume_role_policy = data.aws_iam_policy_document.fargate-profile-assume-role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "fargate-profile-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate-profile.name
}

resource "aws_eks_fargate_profile" "this" {
  count                  = length(var.fargate_profiles)
  cluster_name           = aws_eks_cluster.this.id
  fargate_profile_name   = var.fargate_profiles[count.index]
  pod_execution_role_arn = aws_iam_role.fargate-profile.arn
  subnet_ids             = module.vpc.private_subnets
  tags                   = local.tags

  selector {
    namespace = var.fargate_profiles[count.index]
  }
}
