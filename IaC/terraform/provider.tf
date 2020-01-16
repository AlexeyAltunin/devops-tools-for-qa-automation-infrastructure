provider "google" {
  version     = "3.4.0"
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "europe-west4-a"
}