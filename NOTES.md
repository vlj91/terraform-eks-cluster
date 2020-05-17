module "cluster" {
  source = "https://github.com:vlj91/terraform-eks-cluster"

  cluster_name = "test"
  namespaces = ["api"]
}
