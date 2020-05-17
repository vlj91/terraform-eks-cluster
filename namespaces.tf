resource "kubernetes_namespace" "this" {
  depends_on = [local_file.kubeconfig]
  count = length(var.namespaces)
  
  metadata {
    name = var.namespaces[count.index]
  }
}
