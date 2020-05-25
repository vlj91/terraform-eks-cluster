locals {
  cluster_identity = aws_eks_cluster.this.*.identity
}

resource "aws_cloudwatch_log_group" "cluster" {
  count             = var.create ? 1 : 0
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_period
  tags              = var.tags
}

# Security group rules
resource "aws_security_group" "cluster" {
  count       = var.create ? 1 : 0
  name        = "${var.cluster_name}-eks-cluster"
  description = "EKS cluster security group"
  vpc_id      = module.vpc.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count             = var.create ? 1 : 0
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_eks_cluster" "this" {
  count                     = var.create ? 1 : 0
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.this[count.index].arn
  enabled_cluster_log_types = var.log_enabled_types
  tags                      = var.tags

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
    security_group_ids      = [aws_security_group.cluster[count.index].id]
    subnet_ids              = module.vpc.private_subnets
  }

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role.this,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

# IAM roles and policies
data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = var.create ? 1 : 0
  name_prefix        = "${var.cluster_name}-"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json

  tags = merge(var.tags, {
    "Name" = "eks-${var.cluster_name}-cluster"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this[count.index].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  count      = var.create ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.this[count.index].name
}
