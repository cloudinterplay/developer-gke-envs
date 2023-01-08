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
resource "helm_release" "cert_manager" {
  chart            = "cert-manager"
  name             = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.8.0"
  create_namespace = true
  timeout    = 600
  set {
    name  = "installCRDs"
    value = true
  }
}
resource "helm_release" "arc" {
  depends_on = [helm_release.cert_manager]
  chart      = "actions-runner-controller"
  name       = "actions-runner-controller"
  namespace  = "actions-runner-system"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  version    = "0.21.1"
  create_namespace = true
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
resource "kubectl_manifest" "cert-manager-cluster-issuer" {
  depends_on      = [helm_release.arc]
  validate_schema = false
  yaml_body = <<-YAML
    apiVersion: actions.summerwind.dev/v1alpha1
    kind: RunnerDeployment
    metadata:
      namespace: actions-runner-system
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

