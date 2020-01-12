provider "google" {
  version     = "2.5"
  credentials = "${file("account.json")}"
  project     = "${var.project_name}"
  region      = "europe-west4-a"
}