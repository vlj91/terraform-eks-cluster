variable "create" {
  type = bool
  description = "Optionally create namespaces"
  default = true
}

variable "namespaces" {
  type        = list(string)
  description = "A list of namespaces to create"
  default     = []
}

resource "kubernetes_namespace" "this" {
  count = var.create ? length(var.namespaces) : 0
  
  metadata {
    name = var.namespaces[count.index]
  }
}
