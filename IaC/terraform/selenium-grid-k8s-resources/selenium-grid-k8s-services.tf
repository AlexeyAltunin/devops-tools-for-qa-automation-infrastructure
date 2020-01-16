resource "kubernetes_service" "selenium-hub-svc-internal" {
  metadata {
    name = "selenium-hub-internal"

    labels = {
      app = "selenium-hub"
    }
  }

  spec {
    selector = {
      app = "selenium-hub"
    }
    session_affinity = "None"
    port {
      port        = 4444
      target_port = 4444
      name        = "port0"
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "selenium-hub-svc-external" {
  metadata {
    name = "selenium-hub-external"

    labels = {
      app      = "selenium-hub"
      external = true
    }
  }

  spec {
    selector = {
      app = "selenium-hub"
    }

    external_traffic_policy = "Cluster"
    load_balancer_ip        = ""

    port {
      node_port   = 30109
      port        = 4444
      target_port = 4444
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }
}