resource "kubernetes_namespace" "selenium-namespace" {
  metadata {
    labels = {
      name = "selenium"
    }

    name = "selenium"
  }
}