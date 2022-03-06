# ---------------------------------------------------------------------------------------------------------------------
# Create the Network & corresponding Router to attach other resources to
# Networks that preserve the default route are automatically enabled for Private Google Access to GCP services
# provided subnetworks each opt-in; in general, Private Google Access should be the default.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  name    = "${var.cluster_name}-network"
  project = var.project

  # Always define custom subnetworks- one subnetwork per region isn't useful for an opinionated setup
  auto_create_subnetworks = "false"

  # A global routing mode can have an unexpected impact on load balancers; always use a regional mode
  routing_mode = "REGIONAL"
}

resource "google_compute_router" "vpc_router" {
  name = "${var.cluster_name}-router"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link
}

# ---------------------------------------------------------------------------------------------------------------------
# Public Subnetwork Config
# Public internet access for instances with addresses is automatically configured by the default gateway for 0.0.0.0/0
# External access is configured with Cloud NAT, which subsumes egress traffic for instances without external addresses
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "vpc_subnetwork_public" {
  name = "${var.cluster_name}-subnetwork-public"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range            = cidrsubnet(var.cidr_block, var.cidr_subnetwork_width_delta, 0)

  secondary_ip_range {
    range_name = "public-services"
    ip_cidr_range = cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_width_delta,
      0
    )
  }


}


# ---------------------------------------------------------------------------------------------------------------------
# Private Subnetwork Config
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_subnetwork" "vpc_subnetwork_private" {
  name = "${var.cluster_name}-subnetwork-private"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range = cidrsubnet(
    var.cidr_block,
    var.cidr_subnetwork_width_delta,
    1 * (1 + var.cidr_subnetwork_spacing)
  )

  secondary_ip_range {
    range_name = "private-services"
    ip_cidr_range = cidrsubnet(
      var.secondary_cidr_block,
      var.secondary_cidr_subnetwork_width_delta,
      1 * (1 + var.secondary_cidr_subnetwork_spacing)
    )
  }


}


resource "null_resource" "dependency_setter2" {
  depends_on = [
    google_compute_subnetwork.vpc_subnetwork_public, google_compute_subnetwork.vpc_subnetwork_private
  ]
}


# ---------------------------------------------------------------------------------------------------------------------
# Attach Firewall Rules to allow inbound traffic to tagged instances
# ---------------------------------------------------------------------------------------------------------------------

module "network_firewall" {
  source = "../network-firewall"

  name_prefix = var.name_prefix

  project                               = var.project
  network                               = google_compute_network.vpc.self_link
  allowed_public_restricted_subnetworks = var.allowed_public_restricted_subnetworks

  cluster_name                          = var.cluster_name

  public_subnetwork  = google_compute_subnetwork.vpc_subnetwork_public.self_link
  private_subnetwork = google_compute_subnetwork.vpc_subnetwork_private.self_link
}
