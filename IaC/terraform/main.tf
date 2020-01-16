resource "google_compute_disk" "kvm_disk" {
  name  = "${var.nested_vm_disk_name}"
  zone  = "europe-west4-a"
  image = "ubuntu-1804-lts"
  size  = 50
}

resource "google_compute_image" "selenoid_android_image" {
  name        = "${var.nested_vm_image_name}"
  source_disk = "https://www.googleapis.com/compute/v1/projects/${var.project_name}/zones/europe-west4-a/disks/${var.nested_vm_disk_name}"

  licenses = [
    "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/licenses/ubuntu-1804-lts",
    "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"
  ]

  depends_on = ["google_compute_disk.kvm_disk"]
}

resource "google_compute_firewall" "selenium-docker-based" {
  name    = "selenium-docker-based-terraform"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["4444", "4445", "4446", "8080", "8081", "5900", "7070", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["selenium"]
}

resource "google_compute_instance" "selenoid-web" {
  name         = "selenoid-web-terraform"
  machine_type = "g1-small"
  zone         = "europe-west4-a"

  tags = ["selenium"]

  boot_disk {
    initialize_params {
      size  = 50
      image = "ubuntu-1604-lts"
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "docker-compose up -d"

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  #############################################################################
  # This is the 'local exec' method.
  # Ansible runs from the same host you run Terraform from
  #############################################################################

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = "${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip}"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/docker.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/docker-compose.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/selenoid-web.yml"
  }
}

resource "google_compute_instance" "selenoid-android" {
  name         = "selenoid-android-terraform"
  machine_type = "n1-standard-4"
  zone         = "europe-west3-a"

  tags = ["selenium"]

  boot_disk {
    initialize_params {
      size  = 50
      image = "${var.nested_vm_image_name}"
    }
  }

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "docker-compose up -d"

  metadata = {
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }

  #############################################################################
  # This is the 'local exec' method.
  # Ansible runs from the same host you run Terraform from
  #############################################################################

  provisioner "remote-exec" {
    inline = ["echo 'Hello World'"]

    connection {
      type        = "ssh"
      host        = "${google_compute_instance.selenoid-android.network_interface.0.access_config.0.nat_ip}"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-android.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/docker.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-android.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/docker-compose.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${google_compute_instance.selenoid-android.network_interface.0.access_config.0.nat_ip},' --private-key ${var.private_key_path} ../ansible/selenoid-android.yml"
  }

  depends_on = ["google_compute_image.selenoid_android_image"]
}

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

  depends_on = ["null_resource.configure_kubectl"]
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

  depends_on = ["kubernetes_deployment.selenium-hub"]
}

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

  depends_on = ["kubernetes_deployment.selenium-node-chrome"]
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

  depends_on = ["kubernetes_service.selenium-hub-svc-internal"]
}