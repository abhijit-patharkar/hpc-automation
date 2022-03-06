
/*
######################################################################
# network Module.
######################################################################
*/



module "network" {
  source = "../modules/network"

  name_prefix = var.cluster_name

  project     = var.gcp_project

  region      = var.gcp_region

  cluster_name = var.cluster_name

  cidr_block  = var.network_primary_cidr

  cidr_subnetwork_width_delta = var.network_primary_width

  cidr_subnetwork_spacing     = var.network_primary_spacing

  secondary_cidr_block        = var.network_secondary_cidr

  secondary_cidr_subnetwork_width_delta = var.network_secondary_width

  secondary_cidr_subnetwork_spacing     = var.network_secondary_spacing

  allowed_public_restricted_subnetworks = [""]
}



/*
######################################################################
# cluster module.
######################################################################
*/

module "gke_cluster" {

  source = "../modules/cluster"

  module_depends_on2 = ["${module.network.depended_on2}"]

#  module_depends_on = ["${module.storage.depended_on}"]

  #module_depends_on_firewall = ["${module.network_firewall.depended_on_firewall}"]

  name = var.cluster_name

  cluster_name = var.cluster_name

  project  = var.project

  name_prefix = var.name_prefix

  region = var.region

  deployment_id = var.deployment_id

  capacity = var.nfs_capacity

  service_account = var.service_account

  cluster_nodes = var.cluster_nodes

  nfs_external = var.nfs_external

#  nodes = var.nodes

  filestore_host = var.filestore_host

  filestore_path = var.filestore_path


  location = var.gcp_location

#  initial_node_count = var.cluster_nodes

  cluster_machine_type = var.cluster_machine_type

  cluster_machine_cores = var.cluster_machine_cores

#  localStore_capacity = var.cluster_localStore_capacity

  tool_name = var.tool_name

  vncpassword = var.vncpassword

  tool_version = var.tool_version

  network  = module.network.network

  vpc_network = module.network.private

  subnetwork = module.network.public_subnetwork


}
