locals {
  helm_repository = {
    "stable" = "https://kubernetes-charts.storage.googleapis.com"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  depends_on = [local_file.kubeconfig]
  count = var.kubernetes_dashboard_enabled ? 1 : 0
  name = "kubernetes-dashboard"
  chart = "kubernetes-dashboard"
  repository = local.helm_repository["stable"]
  namespace = "kube-system"
}

resource "helm_release" "metrics-server" {
  depends_on = [local_file.kubeconfig]
  count = var.metrics_server_enabled ? 1 : 0
  name = "metrics-server"
  chart = "metrics-server"
  repository = local.helm_repository["stable"]
  namespace = "kube-system"
}

resource "helm_release" "weave-scope" {
  depends_on = [local_file.kubeconfig]
  count = var.weave_scope_enabled ? 1 : 0
  name = "weave-scope"
  chart = "weave-scope"
  repository = local.helm_repository["stable"]
  namespace = "kube-system"
}

resource "helm_release" "node-problem-detector" {
  depends_on = [local_file.kubeconfig]
  count = var.node_problem_detector_enabled ? 1 : 0
  name = "node-problem-detector"
  chart = "node-problem-detector"
  repository = local.helm_repository["stable"]
  namespace = "kube-system"
}
