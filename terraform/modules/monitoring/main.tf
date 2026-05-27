resource "kubernetes_namespace" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  metadata {
    name = "monitoring"

    labels = {
      "app.kubernetes.io/name" = "monitoring"
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring[0].metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  set = [
    {
      name  = "grafana.adminPassword"
      value = "ChangeMeAfterInstall123!"
    },
    {
      name  = "grafana.service.type"
      value = "ClusterIP"
    }
  ]
}
