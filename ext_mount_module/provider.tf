provider "google" {
    credentials = "${file("/home/tactile-acolyte-282822-2fa69b6f2dbb.json")}"
    project     = var.project
    region      = "us-west1"
}
