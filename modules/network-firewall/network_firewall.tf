data "google_compute_subnetwork" "public_subnetwork" {
  self_link = var.public_subnetwork
}

data "google_compute_subnetwork" "private_subnetwork" {
  self_link = var.private_subnetwork
}

// Define tags as locals so they can be interpolated off of + exported
locals {
  public              = "public"
  public_restricted   = "public-restricted"

  private             = "private"
  private_persistence = "private-persistence"
}

# ---------------------------------------------------------------------------------------------------------------------
# public - allow ingress from anywhere
# ---------------------------------------------------------------------------------------------------------------------
/*
resource "google_compute_firewall" "public_allow_all_inbound" {
  name = "${var.name_prefix}-public-allow-ingress"

  project = var.project
  network = var.network

  target_tags   = [local.public]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "all"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# public - allow ingress from specific sources
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "public_restricted_allow_inbound" {

  count = length(var.allowed_public_restricted_subnetworks) > 0 ? 1 : 0

  name = "${var.name_prefix}-public-restricted-allow-ingress"

  project = var.project
  network = var.network

  target_tags   = [local.public_restricted]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "all"
  }
}

*/
# ---------------------------------------------------------------------------------------------------------------------
# private - allow ingress from within this network
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_firewall" "private_allow_all_network_inbound" {
  name = "${var.cluster_name}-private-allow-ingress"

  project = var.project
  network = var.network

#  target_tags = [local.private]
  direction   = "INGRESS"

  source_tags = ["${var.cluster_name}-nat", "${var.cluster_name}-no-ip"]

  priority = "1000"

  allow {
    protocol = "icmp"
  }

  allow {
   protocol = "tcp"
   ports    = ["1-65535"]
 }

 allow {
  protocol = "udp"
  ports    = ["1-65535"]
}

}

resource "google_compute_firewall" "default" {
  name    = "${var.cluster_name}-ssh-public"
  project = var.project
  network = var.network
  source_ranges = ["0.0.0.0/0"]
  source_tags = ["${var.cluster_name}-nat"]
  target_tags = ["${var.cluster_name}-nat"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["5901"]
  }

  allow {
    protocol = "tcp"
    ports    = ["5900"]
  }

  allow {
    protocol = "tcp"
    ports    = ["5902"]
  }

}

resource "google_compute_firewall" "default2" {
  name    = "${var.cluster_name}-ssh-private"
  project = var.project
  network = var.network
  source_ranges = [
    data.google_compute_subnetwork.public_subnetwork.ip_cidr_range,
    data.google_compute_subnetwork.private_subnetwork.ip_cidr_range,
  ]
  source_tags = ["${var.cluster_name}-no-ip"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }



}

# ---------------------------------------------------------------------------------------------------------------------
# private-persistence - allow ingress from `private` and `private-persistence` instances in this network
# ---------------------------------------------------------------------------------------------------------------------
/*
resource "google_compute_firewall" "private_allow_restricted_network_inbound" {
  name = "${var.name_prefix}-allow-restricted-inbound"

  project = var.project
  network = var.network

  target_tags = [local.private_persistence]
  direction   = "INGRESS"

  # source_tags is implicitly within this network; tags are only applied to instances that rest within the same network
  source_tags = [local.private, local.private_persistence]

  priority = "1000"

  allow {
    protocol = "all"
  }
}
*/
/*
resource "null_resource" "dependency_setter_firewall" {
  depends_on = [
    google_compute_firewall.private_allow_restricted_network_inbound
  ]
}
*/
