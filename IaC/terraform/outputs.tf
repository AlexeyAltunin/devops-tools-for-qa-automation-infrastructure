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

output "Selenium-Grid" {
  value = "http://${kubernetes_service.selenium-hub-svc-external.load_balancer_ingress[0].ip}:4444/grid/console"
}