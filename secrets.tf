# Grafana
resource "random_password" "grafana-admin-password" {
  count = var.create && var.grafana_enabled ? 1 : 0
  length = 32
}

resource "aws_ssm_parameter" "grafana-admin-password" {
  count = var.create && var.grafana_enabled ? 1 : 0
  name = "/cluster/${var.cluster_name}/grafana/admin/password"
  type = "SecureString"
  value = random_password.grafana-admin-password[count.index].result
}

resource "random_password" "grafana-readonly-password" {
  count = var.create && var.grafana_enabled ? 1 : 0
  length = 32
}

resource "aws_ssm_parameter" "grafana-readonly-passowrd" {
  count = var.create && var.grafana_enabled ? 1 : 0
  name = "/cluster/${var.cluster_name}/grafana/readonly/password"
  type = "SecureString"
  value = random_password.grafana-readonly-password[count.index].result
}

resource "kubernetes_secret" "grafana-admin-user" {
  count = var.create && var.grafana_enabled ? 1 : 0
  depends_on = [local_file.kubeconfig]

  metadata {
    name = "grafana-admin-user"
    namespace = "kube-system"
  }

  data = {
    "admin-user"     = "admin"
    "admin-password" = aws_ssm_parameter.grafana-admin-password[count.index].value
  }
}