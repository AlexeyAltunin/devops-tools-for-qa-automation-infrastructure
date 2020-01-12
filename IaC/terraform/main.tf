resource "google_compute_disk" "kvm_disk" {
  name  = "${var.nested_vm_disk_name}"
  zone  = "europe-west4-a"
  image = "ubuntu-1804-lts"
  size  = 50
}

resource "google_compute_image" "selenoid_android_image" {
  name = "${var.nested_vm_image_name}"
  source_disk = "https://www.googleapis.com/compute/v1/projects/${var.project_name}/zones/europe-west4-a/disks/${var.nested_vm_disk_name}"

  licenses = ["https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"]

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
  zone         = "europe-west4-a"

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