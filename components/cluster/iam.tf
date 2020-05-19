# IAM roles and policies
data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count = var.create ? 1 : 0
  name_prefix = "${var.name}-"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  tags = merge(var.tags, {
    "Name" = "eks-${var.name}-cluster"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this[count.index].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  count = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.this[count.index].name
}