resource "local_file" "kubeconfig" {
  count    = var.create ? 1 : 0
  filename = "${path.module}/kubeconfig-${join("", aws_eks_cluster.this.*.id)}"
  content = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint            = aws_eks_cluster.this[count.index].endpoint
    cluster_auth_base64 = aws_eks_cluster.this[count.index].certificate_authority[0].data
    cluster_arn         = aws_eks_cluster.this[count.index].arn
    cluster_name        = aws_eks_cluster.this[count.index].id
    region              = data.aws_region.current.name
  })
}

output "kubeconfig" {
  value = templatefile("${path.module}/kubeconfig.tpl", {
    endpoint = join("", aws_eks_cluster.this.*.endpoint)
    cluster_auth_base64 = join("", aws_eks_cluster.this.*.certificate_authority.0.data)
    cluster_arn = join("", aws_eks_cluster.this.*.arn)
    cluster_name = join("", aws_eks_cluster.this.*.id)
    region = data.aws_region.current.name
  })
}
