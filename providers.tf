provider "kubernetes" {
  config_path = "${path.module}/kubeconfig-${join("", aws_eks_cluster.this.*.id)}"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig-${join("", aws_eks_cluster.this.*.id)}"
  }
}
