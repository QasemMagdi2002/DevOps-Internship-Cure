locals {
  namespace                   = "kube-system"
  service_account_name        = "aws-load-balancer-controller"
  oidc_provider_url_no_scheme = replace(var.cluster_oidc_issuer_url, "https://", "")
}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-alb-controller-irsa-role"

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

# Simplified controller policy for demo speed.
# For stricter production, replace this with the official AWSLoadBalancerControllerIAMPolicy JSON.
resource "aws_iam_role_policy_attachment" "elastic_load_balancing_full_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.service_account_name
    namespace = local.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }

    labels = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
}

resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  namespace  = local.namespace
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
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
