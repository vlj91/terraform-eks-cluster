variable "create" {
  type = bool
  description = "Optionally create the worker nodes"
  default = true
}

variable "cluster_name" {
  type = string
  description = "Cluster name"
}

variable "private_subnet_ids" {
  type = list(string)
  description = "A list of private subnet IDs"
  default = []
}

variable "tags" {
  type = map(string)
  description = "A list of tags"
  default = {}
}


variable "workers_desired_size" {
  type    = number
  default = 1
}

variable "workers_min_size" {
  type    = number
  default = 1
}

variable "workers_max_size" {
  type    = number
  default = 1
}

resource "aws_eks_node_group" "this" {
  count           = var.create ? 1 : 0
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-eks-workers"
  node_role_arn   = aws_iam_role.eks-workers[count.index].arn
  subnet_ids      = var.private_subnet_ids
  tags            = var.tags

  scaling_config {
    desired_size = var.workers_desired_size
    min_size     = var.workers_min_size
    max_size     = var.workers_max_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-workers-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-workers-AmazonEC2ContainerRegistryReadOnly,
  ]
}
