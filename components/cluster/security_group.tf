# Security group rules
resource "aws_security_group" "cluster" {
  count       = var.create ? 1 : 0
  name        = "${var.name}-eks-cluster"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count = var.create ? 1 : 0
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_ingress_worker_https" {
  count = var.create && var.workers_security_group_id != "none" ? 1 : 0
  description              = "Allow pods to communicate with the EKS cluster API"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster[count.index].id
  source_security_group_id = var.workers_security_group_id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}