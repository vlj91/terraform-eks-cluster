resource "helm_release" "node-problem-detector" {
  count      = var.create && var.node_problem_detector_enabled ? 1 : 0
  name       = "node-problem-detector"
  chart      = "node-problem-detector"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}