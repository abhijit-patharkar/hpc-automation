
variable "name_prefix" {
  description = "A name prefix used in resource names to ensure uniqueness across a project."
  type        = string
}

variable "network_secondary_spacing" {
}

variable "network_secondary_width" {
}

variable "cluster_nodes" {
  default = ""
}

variable "cluster_machine_type" {
  default = ""
}

variable "deployment_id" {
}

variable "cluster_machine_cores" {
  default = ""
}

variable "vncpassword" {
  
}

variable "cluster_localStore_capacity" {
  default = ""
}

variable "network_primary_spacing" {

}

variable "network_primary_width" {

}

variable "network_primary_cidr"{

}

variable "network_secondary_cidr"{

}

variable "gcp_region" {

}

variable "project_id" {}

variable "gcp_prefix" {}

variable "gcp_project" {}

variable "gcp_location" {}

#variable "nfs_name" {}

#variable "nfs_zone" {}

variable "nfs_capacity" {}

variable "nfs_external" {}


#variable "image_name" {}

#variable "image_repository_name" {}

#variable "image_tag" {}

variable "tool_name" {}

variable "service_account" {}

variable "tool_version" {}

variable "filestore_host" {}

variable "filestore_path" {}
# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID where all resources will be launched."
  type        = string
}

variable "location" {
  description = "The location (region or zone) of the GKE cluster."
  type        = string
}

variable "region" {
  description = "The region for the network. If the cluster is regional, this must be the same region. Otherwise, it should be the region of the zone."
  type        = string
}



# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
  default     = "vasten-private-cluster"
}



variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation (size must be /28) to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
  default     = "10.5.0.0/28"
}

# For the example, we recommend a /16 network for the VPC. Note that when changing the size of the network,
# you will have to adjust the 'cidr_subnetwork_width_delta' in the 'vpc_network' -module accordingly.
variable "vpc_cidr_block" {
  description = "The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.3.0.0/16"
}

# For the example, we recommend a /16 network for the secondary range. Note that when changing the size of the network,
# you will have to adjust the 'cidr_subnetwork_width_delta' in the 'vpc_network' -module accordingly.
variable "vpc_secondary_cidr_block" {
  description = "The IP address range of the VPC's secondary address range in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher than /27."
  type        = string
  default     = "10.4.0.0/16"
}

variable "ip_addrs" {
  type = list(string)
  default = ["10.0.0.0/16", "10.0.0.1/16"]
}
