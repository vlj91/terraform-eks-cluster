resource "helm_release" "metrics-server" {
  count      = var.create && var.metrics_server_enabled ? 1 : 0
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}