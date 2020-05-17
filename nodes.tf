resource "aws_eks_node_group" "this" {
  count           = var.node_group_enabled ? 1 : 0
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-eks-workers"
  node_role_arn   = aws_iam_role.eks-workers.arn
  subnet_ids      = module.vpc.private_subnets
  tags            = local.tags

  scaling_config {
    desired_size = var.workers_desired_size
    min_size     = var.workers_min_size
    max_size     = var.workers_max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-workers-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.this
  ]
}

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
  name               = "${var.cluster_name}-eks-workers"
  assume_role_policy = data.aws_iam_policy_document.eks-workers-assume-role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-workers.name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-workers.name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-workers.name
}
