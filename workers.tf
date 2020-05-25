resource "aws_eks_node_group" "this" {
  count           = var.create && var.create_workers ? 1 : 0
  cluster_name    = aws_eks_cluster.this[count.index].id
  node_group_name = "${var.cluster_name}-eks-workers"
  node_role_arn   = aws_iam_role.eks-workers[count.index].arn
  subnet_ids      = module.vpc.private_subnets
  tags            = var.tags

  scaling_config {
    desired_size = var.workers_desired_size
    min_size     = var.workers_min_size
    max_size     = var.workers_max_size
  }

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.eks-workers-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "workers" {
  count       = var.create ? 1 : 0
  depends_on  = [aws_eks_cluster.this]
  name        = "${var.cluster_name}-eks-workers"
  description = "Security group for all EKS worker nodes"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "workers_egress_internet" {
  count             = var.create ? 1 : 0
  depends_on        = [aws_eks_cluster.this]
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count                    = var.create ? 1 : 0
  depends_on               = [aws_eks_cluster.this]
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = aws_security_group.workers[count.index].id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count                    = var.create ? 1 : 0
  depends_on               = [aws_eks_cluster.this]
  description              = "Allow workers pods to receive communication from the cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = aws_security_group.cluster[count.index].id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count                    = var.create ? 1 : 0
  depends_on               = [aws_eks_cluster.this]
  description              = "Allow workers Kubelets to receive communication from the cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = aws_security_group.cluster[count.index].id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count                    = var.create ? 1 : 0
  depends_on               = [aws_eks_cluster.this]
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = aws_security_group.cluster[count.index].id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_ingress_workers_https" {
  count                    = var.create ? 1 : 0
  depends_on               = [aws_eks_cluster.this, aws_security_group.cluster]
  description              = "Allow pods to communicate with the EKS cluster API"
  protocol                 = "tcp"
  security_group_id        = join("", aws_security_group.cluster.*.id)
  source_security_group_id = aws_security_group.workers[count.index].id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

data "aws_iam_policy_document" "eks-workers-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
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
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-workers[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEKS_CNI_Policy" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-workers[count.index].name
}

resource "aws_iam_role_policy_attachment" "eks-workers-AmazonEC2ContainerRegistryReadOnly" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-workers[count.index].name
}
