output "kubeconfig" {
  value = templatefile("${path.module}/templates/kubeconfig.tpl", {
    endpoint            = aws_eks_cluster.this.endpoint
    cluster_auth_base64 = aws_eks_cluster.this.certificate_authority[0].data
    cluster_arn         = aws_eks_cluster.this.arn
    cluster_name        = aws_eks_cluster.this.id
    region              = data.aws_region.current.name
  })
}

output "oidc_assume_role_json" {
  value = data.aws_iam_policy_document.oidc-assume-role.json
}

output "cluster_oidc_issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
