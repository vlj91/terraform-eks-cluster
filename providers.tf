provider "kubernetes" {
  config_path = "${path.module}/kubeconfig-${aws_eks_cluster.this.id}"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig-${aws_eks_cluster.this.id}"
  }
}
