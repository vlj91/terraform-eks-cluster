variable "create" {
  type = bool
  description = "Optionally create the kubeconfig template"
  default = true
}

variable "cluster_name" {
  type = string
  description = "Cluster name"
}

variable "region" {
  type = string
  description = "Region name"
}

data "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0
  name = var.cluster_name
}

resource "local_file" "kubeconfig" {
  count = var.create ? 1 : 0
  filename = "${path.module}/kubeconfig-${data.aws_eks_cluster.this[count.index].id}"

  content = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint            = data.aws_eks_cluster.this[count.index].endpoint
    cluster_auth_base64 = data.aws_eks_cluster.this[count.index].certificate_authority[0].data
    cluster_arn         = data.aws_eks_cluster.this[count.index].arn
    cluster_name        = data.aws_eks_cluster.this[count.index].id
    region              = var.region
  })
}

output "rendered" {
  value = var.create == false ? "" : templatefile("${path.module}/kubeconfig.tpl", {
    endpoint            = data.aws_eks_cluster.this[0].endpoint
    cluster_auth_base64 = data.aws_eks_cluster.this[0].certificate_authority[0].data
    cluster_arn         = data.aws_eks_cluster.this[0].arn
    cluster_name        = data.aws_eks_cluster.this[0].id
    region              = var.region
  })
}
