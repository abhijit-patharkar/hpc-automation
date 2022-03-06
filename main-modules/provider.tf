provider "google" {
    credentials = "${file("/home/scriptuit/Downloads/third-crossing-286519-941485c8a65e.json")}"
    project     = var.project
    region      = "us-west1"
    version    = "3.20.0"
}
