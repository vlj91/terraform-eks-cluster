resource "helm_release" "kubernetes-dashboard" {
  count      = var.create && var.kubernetes_dashboard_enabled ? 1 : 0
  name       = "kubernetes-dashboard"
  chart      = "kubernetes-dashboard"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}