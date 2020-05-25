locals {
  # TODO: add var to allow merging default repositories with additional repositories
  helm_repository = {
    "stable" = "https://kubernetes-charts.storage.googleapis.com"
  }
}

resource "helm_release" "metrics-server" {
  depends_on = [local_file.kubeconfig]
  count      = var.create && var.metrics_server_enabled ? 1 : 0
  name       = "metrics-server"
  chart      = "metrics-server"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}

resource "helm_release" "weave-scope" {
  depends_on = [local_file.kubeconfig]
  count      = var.create && var.weave_scope_enabled ? 1 : 0
  name       = "weave-scope"
  chart      = "weave-scope"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}

resource "helm_release" "kubernetes-dashboard" {
  depends_on = [local_file.kubeconfig]
  count      = var.create && var.kubernetes_dashboard_enabled ? 1 : 0
  name       = "kubernetes-dashboard"
  chart      = "kubernetes-dashboard"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}

resource "helm_release" "prometheus" {
  depends_on = [local_file.kubeconfig]
  count      = var.create && var.prometheus_enabled ? 1 : 0
  name       = "prometheus"
  chart      = "prometheus"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"

  set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = "gp2"
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = "gp2"
  }
}

resource "helm_release" "node-problem-detector" {
  depends_on = [local_file.kubeconfig]
  count      = var.create && var.node_problem_detector_enabled ? 1 : 0
  name       = "node-problem-detector"
  chart      = "node-problem-detector"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"
}

resource "helm_release" "grafana" {
  depends_on = [local_file.kubeconfig, kubernetes_secret.grafana-admin-user]
  count      = var.create && var.grafana_enabled ? 1 : 0
  name       = "grafana"
  chart      = "grafana"
  repository = local.helm_repository["stable"]
  namespace  = "kube-system"


  values = [
    "${file("${path.module}/config/grafana.yaml")}"
  ]

  set {
    name = "admin.existingSecret"
    value = "grafana-admin-user"
  }

  set {
    name = "persistence.storageClassName"
    value = "gp2"
  }

  set {
    name = "persistence.enabled"
    value = "true"
  }

  set {
    name = "adminPassword"
    value = "AirtaskerAdmin!"
  }
}
