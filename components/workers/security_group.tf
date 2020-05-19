# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
resource "aws_security_group" "workers" {
  count = var.create ? 1 : 0
  name        = "${var.cluster_name}-eks-workers"
  description = "Security group for all EKS worker nodes"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "workers_egress_internet" {
  count = var.create ? 1 : 0
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  count = var.create ? 1 : 0
  description              = "Allow node to communicate with each other"
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = aws_security_group.workers[count.index].id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  count = var.create ? 1 : 0
  description              = "Allow workers pods to receive communication from the cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  count = var.create ? 1 : 0
  description              = "Allow workers Kubelets to receive communication from the cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  count = var.create ? 1 : 0
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers[count.index].id
  source_security_group_id = var.cluster_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}
