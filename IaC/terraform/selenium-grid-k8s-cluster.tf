resource "google_container_cluster" "selenium-grid-k8s" {
  name     = "selenium-grid-k8s-terraform"
  location = "europe-west3-a"

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "selenium-grid-k8s-preemptible-nodes" {
  name       = "selenium-node-pool"
  location   = "europe-west3-a"
  cluster    = google_container_cluster.selenium-grid-k8s.name
  node_count = 2

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  depends_on = ["google_container_cluster.selenium-grid-k8s"]
}

resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.selenium-grid-k8s.name} --zone ${google_container_cluster.selenium-grid-k8s.location} --project ${var.project_name}"
  }

  depends_on = ["google_container_node_pool.selenium-grid-k8s-preemptible-nodes"]
}