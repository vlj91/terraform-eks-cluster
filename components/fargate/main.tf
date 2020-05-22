variable "create" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
  default = []
}

variable "namespaces" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
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
  count              = var.create ? 1 : 0
  name               = "${var.cluster_name}-eks-fargate"
  assume_role_policy = data.aws_iam_policy_document.fargate-profile-assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "fargate-profile-AmazonEKSFargatePodExecutionRolePolicy" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate-profile[count.index].name
}

resource "aws_eks_fargate_profile" "this" {
  count                  = var.create ? length(var.namespaces) : 0
  cluster_name           = var.cluster_name
  fargate_profile_name   = var.namespaces[count.index]
  pod_execution_role_arn = join("", aws_iam_role.fargate-profile.*.arn)
  subnet_ids             = var.private_subnet_ids
  tags                   = var.tags

  selector {
    namespace = var.namespaces[count.index]
  }
}
