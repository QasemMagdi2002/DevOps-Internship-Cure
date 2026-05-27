locals {
  namespace                   = "kube-system"
  service_account_name        = "external-dns"
  oidc_provider_url_no_scheme = replace(var.cluster_oidc_issuer_url, "https://", "")
}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-external-dns-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url_no_scheme}:sub" = "system:serviceaccount:${local.namespace}:${local.service_account_name}"
            "${local.oidc_provider_url_no_scheme}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_policy" "this" {
  name        = "${var.name_prefix}-external-dns-policy"
  description = "Allow ExternalDNS to manage Route53 records for CURE."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ChangeRecords"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/${var.hosted_zone_id}"
      },
      {
        Sid    = "ListZonesAndRecords"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.service_account_name
    namespace = local.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }

    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
}

resource "helm_release" "this" {
  name       = "external-dns"
  namespace  = local.namespace
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"

  set = [
    {
      name  = "provider.name"
      value = "aws"
    },
    {
      name  = "policy"
      value = "sync"
    },
    {
      name  = "registry"
      value = "txt"
    },
    {
      name  = "txtOwnerId"
      value = var.cluster_name
    },
    {
      name  = "domainFilters[0]"
      value = var.root_domain_name
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = local.service_account_name
    }
  ]

  depends_on = [
    kubernetes_service_account.this
  ]
}
