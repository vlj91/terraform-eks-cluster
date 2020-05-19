data "aws_iam_policy_document" "eks-workers-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks-workers" {
  count              = var.create ? 1 : 0
  name               = "${var.cluster_name}-eks-workers"
  assume_role_policy = data.aws_iam_policy_document.eks-workers-assume-role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEKSWorkerNodePolicy" {
  count              = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-workers[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEKS_CNI_Policy" {
  count              = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-workers[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEC2ContainerRegistryReadOnly" {
  count              = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-workers[count.index].name
}
