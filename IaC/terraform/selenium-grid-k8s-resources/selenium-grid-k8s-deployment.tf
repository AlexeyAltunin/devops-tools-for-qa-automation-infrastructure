resource "kubernetes_deployment" "selenium-hub" {
  metadata {
    name = "selenium-hub"
    labels = {
      app = "selenium-hub"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "selenium-hub"
      }
    }

    template {
      metadata {
        labels = {
          app = "selenium-hub"
        }
      }

      spec {
        container {
          image = "selenium/hub:3.141"
          name  = "selenium-hub"

          port {
            container_port = 4444
          }

          resources {
            limits {
              cpu    = ".5"
              memory = "1000Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/wd/hub/status"
              port = 4444
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/wd/hub/status"
              port = 4444
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "selenium-node-chrome" {
  metadata {
    name = "selenium-node-chrome"
    labels = {
      app = "selenium-node-chrome"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "selenium-node-chrome"
      }
    }

    template {
      metadata {
        labels = {
          app = "selenium-node-chrome"
        }
      }

      spec {
        volume {
          name = "dshm"

          empty_dir {
            medium = "Memory"
          }
        }

        container {
          image = "selenium/node-chrome-debug:3.141"
          name  = "selenium-node-chrome"

          port {
            container_port = 5555
          }

          volume_mount {
            mount_path = "/dev/shm"
            name       = "dshm"
          }

          env {
            name  = "HUB_HOST"
            value = "selenium-hub-internal"
          }

          env {
            name  = "HUB_PORT"
            value = "4444"
          }

          resources {
            limits {
              cpu    = ".5"
              memory = "1000Mi"
            }
          }
        }
      }
    }
  }
}