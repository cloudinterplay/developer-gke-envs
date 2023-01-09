terraform {
  required_version = ">=0.13"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}
provider "kubernetes" {
  config_context = "docker-desktop"
  config_path    = "~/.kube/config"
}
provider "kubectl" {
  config_context = "docker-desktop"
  config_path    = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_context = "docker-desktop"
    config_path    = "~/.kube/config"
  }
}
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}
resource "helm_release" "cert_manager" {
  depends_on = [kubernetes_namespace.cert_manager]
  chart            = "cert-manager"
  name             = "cert-manager"
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  repository       = "https://charts.jetstack.io"
  version          = "v1.8.0"
  timeout    = 600
  set {
    name  = "installCRDs"
    value = true
  }
}
resource "kubernetes_namespace" "actions_runner_controller" {
  metadata {
    name = "actions-runner-controller"
  }
}
resource "helm_release" "actions_runner_controller" {
  depends_on = [helm_release.cert_manager]
  chart      = "actions-runner-controller"
  name       = "actions-runner-controller"
  namespace  = kubernetes_namespace.actions_runner_controller.metadata[0].name
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  version    = "0.21.1"
  timeout    = 600
  set {
    name  = "authSecret.create"
    value = true
  }
  set_sensitive {
    name  = "authSecret.github_token"
    value = var.githubToken
  }
}
resource "kubernetes_namespace" "actions_runners" {
  depends_on      = [helm_release.actions_runner_controller]
  metadata {
    name = "actions-runners"
  }
}
resource "kubectl_manifest" "cert-manager-cluster-issuer" {
  depends_on      = [kubernetes_namespace.actions_runners]
  validate_schema = false
  yaml_body = <<-YAML
    apiVersion: actions.summerwind.dev/v1alpha1
    kind: RunnerDeployment
    metadata:
      namespace: ${kubernetes_namespace.actions_runners.metadata[0].name}
      name: ${split("/",var.githubRepository)[1]}
    spec:
      replicas: 2
      template:
        spec:
          ephemeral: false
          repository: ${var.githubRepository}
          env: []
          labels:
          - self-hosted
          group: default
          dockerVolumeMounts:
          - mountPath: /var/lib/docker
            name: docker
          volumeMounts:
          - mountPath: /tmp
            name: tmp
          - mountPath: /home/runner/.config
            name: gcp-credentials
          volumes:
          - name: docker
            emptyDir:
              medium: Memory
          - name: work
            emptyDir:
              medium: Memory
          - name: tmp
            emptyDir:
              medium: Memory
          - name: gcp-credentials
            hostPath:
              path: /Users/${var.userID}/.config/
  YAML
}
