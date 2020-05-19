variable "vpc_id" {
  type = string
}

variable "cluster_security_group_id" {
  type = string
}

output "security_group_id" {
  value = join("", aws_security_group.workers.*.id)
}
