locals {
  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "k8s.io/cluster/${var.cluster_name}"        = "owned"
  })
}
