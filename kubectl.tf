resource "local_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig-${aws_eks_cluster.this.id}"

  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    endpoint            = aws_eks_cluster.this.endpoint
    cluster_auth_base64 = aws_eks_cluster.this.certificate_authority[0].data
    cluster_arn         = aws_eks_cluster.this.arn
    cluster_name        = aws_eks_cluster.this.id
    region              = data.aws_region.current.name
  })
}
