resource "aws_eks_cluster" "this" {
  count                     = var.create ? 1 : 0
  name                      = var.name
  role_arn                  = aws_iam_role.this[count.index].arn
  enabled_cluster_log_types = var.log_enabled_types
  tags                      = var.tags

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
    security_group_ids      = [aws_security_group.cluster[count.index].id]
    subnet_ids              = var.private_subnet_ids
  }

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role.this,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}
