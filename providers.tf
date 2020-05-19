resource "local_file" "kubeconfig" {
  content  = module.kubeconfig.rendered
  filename = "${path.module}/kubeconfig-${module.cluster.id}"
}

provider "kubernetes" {
  config_path = "${path.module}/kubeconfig-${module.cluster.id}"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig-${module.cluster.id}"
  }
}
