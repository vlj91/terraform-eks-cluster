resource "helm_release" "grafana" {
  count      = var.create && var.metrics_server_enabled ? 1 : 0
  name       = "grafana"
  chart      = "grafana"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"

  set {
    name = "ingress.enabled"
    value = "true"
  }
}
