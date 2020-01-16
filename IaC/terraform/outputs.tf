output "Selenoid-Web" {
  value = "http://${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip}:8081/#/"
}

output "Selenoid-Web-ssh" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip} -i ${var.private_key_path}"
}

output "Selenoid-Android" {
  value = "http://${google_compute_instance.selenoid-android.network_interface.0.access_config.0.nat_ip}:8081/#/"
}

output "Selenoid-Android-ssh" {
  value = "ssh ${var.ssh_user}@${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip} -i ${var.private_key_path}"
}

output "Cluster-Endpoint" {
  value = "${google_container_cluster.selenium-grid-k8s.endpoint}"
}