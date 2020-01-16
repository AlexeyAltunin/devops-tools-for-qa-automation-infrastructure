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