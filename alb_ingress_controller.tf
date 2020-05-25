data "external" "thumbprint" {
  program = ["${path.module}/bin/get_thumbprint.sh", data.aws_region.current.name]
}

resource "aws_iam_openid_connect_provider" "this" {
  depends_on      = [aws_eks_cluster.this]
  count           = var.create ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = flatten(concat(aws_eks_cluster.this[count.index].identity[*].oidc.0.issuer, [""]))[0]
}

data "aws_iam_policy_document" "oidc-assume-role" {
  depends_on = [aws_eks_cluster.this]
  count      = var.create ? 1 : 0

  statement {
    sid     = "OIDC"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.this[count.index].identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-alb-ingress-controller"
      ]
    }

    principals {
      type = "Federated"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.this[count.index].identity[0].oidc[0].issuer, "https://", "")}"
      ]
    }
  }
}

resource "aws_iam_role" "alb-ingress" {
  count              = var.create ? 1 : 0
  name               = "${var.cluster_name}-alb-ingress-controller"
  description        = "EKS ALB ingress controller"
  assume_role_policy = data.aws_iam_policy_document.oidc-assume-role[count.index].json
  tags               = var.tags
}

data "aws_iam_policy_document" "alb-ingress" {
  statement {
    sid       = "acm"
    resources = ["*"]

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate"
    ]
  }

  statement {
    sid       = "ec2"
    resources = ["*"]

    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress"
    ]
  }

  statement {
    sid       = "elasticloadbalancing"
    resources = ["*"]

    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL"
    ]
  }

  statement {
    sid       = "iam"
    resources = ["*"]

    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates"
    ]
  }

  statement {
    sid       = "wafregional"
    resources = ["*"]

    actions = [
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL"
    ]
  }

  statement {
    sid       = "tag"
    resources = ["*"]

    actions = [
      "tag:GetResources",
      "tag:TagResources"
    ]
  }

  statement {
    sid       = "waf"
    resources = ["*"]

    actions = [
      "waf:GetWebACL"
    ]
  }
}

resource "aws_iam_role_policy" "alb-ingress" {
  count  = var.create ? 1 : 0
  name   = "${var.cluster_name}-eks-alb-ingress"
  role   = aws_iam_role.alb-ingress[count.index].name
  policy = data.aws_iam_policy_document.alb-ingress.json
}

resource "kubernetes_cluster_role" "alb-ingress" {
  count = var.create ? 1 : 0
  metadata {
    name = "alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources = [
      "configmaps",
      "events",
      "ingresses",
      "ingresses/status",
      "services"
    ]
    verbs = [
      "create",
      "get",
      "list",
      "update",
      "watch",
      "patch"
    ]
  }

  rule {
    api_groups = ["", "extensions"]
    resources = [
      "endpoints",
      "nodes",
      "pods",
      "secrets",
      "services",
      "namespaces"
    ]
    verbs = [
      "get",
      "list",
      "watch"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "alb-ingress" {
  count      = var.create ? 1 : 0
  depends_on = [kubernetes_cluster_role.alb-ingress]

  metadata {
    name = "alb-ingress-controller"

    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "alb-ingress-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "alb-ingress-controller"
    namespace = "kube-system"
  }
}

resource "kubernetes_service_account" "alb-ingress" {
  count = var.create ? 1 : 0
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb-ingress[count.index].arn
    }

    labels = {
      "app.kubernetes.io/name"       = "alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_deployment" "alb-ingress-controller" {
  count      = var.create ? 1 : 0
  depends_on = [kubernetes_cluster_role_binding.alb-ingress]

  metadata {
    name      = "aws-alb-ingress-controller"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name"       = "aws-alb-ingress-controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "aws-alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "aws-alb-ingress-controller"
        }

        annotations = {
          "iam.amazonaws.com/role" = aws_iam_role.alb-ingress[count.index].arn
        }
      }

      spec {
        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["aws-alb-ingress-controller"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        automount_service_account_token  = true
        dns_policy                       = "ClusterFirst"
        restart_policy                   = "Always"
        service_account_name             = kubernetes_service_account.alb-ingress[count.index].metadata[0].name
        termination_grace_period_seconds = 60

        container {
          name                     = "server"
          image                    = "docker.io/amazon/aws-alb-ingress-controller:v1.1.4"
          image_pull_policy        = "Always"
          termination_message_path = "/dev/termination-log"

          args = [
            "--ingress-class=alb",
            "--cluster-name=${aws_eks_cluster.this[count.index].id}",
            "--aws-vpc-id=${module.vpc.vpc_id}",
            "--aws-region=${data.aws_region.current.name}",
            "--aws-max-retries=10",
          ]
        }
      }
    }
  }
}
