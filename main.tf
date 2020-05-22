module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = var.cluster_name
  cidr                 = "10.80.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.80.1.0/24", "10.80.2.0/24", "10.80.3.0/24"]
  public_subnets       = ["10.80.11.0/24", "10.80.12.0/24", "10.80.13.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "cluster" {
  source = "./components/cluster"

  create                    = var.create
  name                      = var.cluster_name
  private_subnet_ids        = module.vpc.private_subnets
  vpc_id                    = module.vpc.vpc_id
}

module "kubeconfig" {
  source = "./components/kubeconfig"

  create       = var.create
  cluster_name = module.cluster.id
  region       = data.aws_region.current.name
}

module "addons" {
  source = "./components/addons"

  create = var.create
  labels = module.cluster.labels
}

module "namespaces" {
  source = "./components/namespaces"

  create     = var.create
  namespaces = var.namespaces
}

module "fargate" {
  source = "./components/fargate"

  create             = var.create
  cluster_name       = module.cluster.id
  namespaces         = var.fargate_enabled_namespaces
  private_subnet_ids = module.vpc.private_subnets
}

module "workers" {
  source = "./components/workers"

  create             = var.create
  cluster_name       = module.cluster.id
  cluster_security_group_id = module.cluster.cluster_security_group_id
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}
