output "Selenoid-Web" {
  value = "http://${google_compute_instance.selenoid-web.network_interface.0.access_config.0.nat_ip}"
}