resource "helm_release" "prometheus" {
  count      = var.create && var.prometheus_enabled ? 1 : 0
  name       = "prometheus"
  chart      = "prometheus"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}
