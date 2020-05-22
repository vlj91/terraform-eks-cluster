# Security group rules
resource "aws_security_group" "cluster" {
  count       = var.create ? 1 : 0
  name        = "${var.name}-eks-cluster"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  count             = var.create ? 1 : 0
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[count.index].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

