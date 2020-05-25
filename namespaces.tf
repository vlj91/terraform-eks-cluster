resource "kubernetes_namespace" "this" {
  count      = var.create ? length(var.namespaces) : 0
  depends_on = [local_file.kubeconfig]

  metadata {
    name = var.namespaces[count.index]
  }
}
