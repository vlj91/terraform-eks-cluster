resource "helm_release" "weave-scope" {
  count      = var.create && var.weave_scope_enabled ? 1 : 0
  name       = "weave-scope"
  chart      = "weave-scope"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}