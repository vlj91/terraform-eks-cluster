resource "aws_cloudwatch_log_group" "cluster" {
  count = var.create ? 1 : 0
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = var.log_retention_period
  tags              = var.tags
}