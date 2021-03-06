#project = "bold-vial-279601"
region = "us-west1"
location = "us-west1-a"
#name_prefix = "vasten"
#project_id = "bold-vial-279601"

# Configuration properties for the vasten-cloud CLI utility
# Make sure the properties file is properly configured to make sure the Cluster is configured properly


#
# Cloud Provider
#

# Possible values are "GCP", "AZURE", "AWS"
# v0.1 supports only GCP
vasten_cloud="GCP"


#
# GCP Configuration
#

# Project name (prefixed to the cloud tags)
# Possible values:
#gcp_project="bold-vial-279601"

# The region to setup the cluster in
# Possible values:
#gcp_region="us-west1"

# The location to setup the cluster in
# Possible values:
#gcp_location="us-west1-a"

# The prefix to tag the cloud resources
# Possible values:
#gcp_prefix="vasten"

# The ID of the project created in GCP for setting up the cloud resources
#gcp_projectId="273997053005"

# The path to the key file which has aceess to cloud resources
#gcp_keyPath="/home/scriptuit/Downloads/bold-vial-279601-16d3eab6ed31.json"

#
# Network Configuration
#

# Primary Network Configuration
#network_primary_cidr="10.0.0.0/16"
#network_primary_width = 4
#network_primary_spacing = 0

# Secondary Network Configuration
#network_secondary_cidr="10.1.0.0/16"
#network_secondary_width=4
#network_secondary_spacing=0

# Network Logs Enabled (Possible values: true/false)
#network_logs=true

#
# Operating System
#
#os_name="centos"
#os_version="7"

#
# Tool Details
#
tool_name="vasten"
tool_version="8x"

#
# Registry
#
#image_repository_name = "gcr.io/${project}/${tool_name}:${tool_version}"
#image_name = "gcr.io/${project}/${tool_name}"
#image_tag = "ioplkj"
#
# Cluster
#
cluster_name="vasten0v"
cluster_nodes=2
cluster_machine_type="n1-standard"
cluster_machine_cores=1
#cluster_localStore_capacity=30

#
# NFS
#


#nfs_name = "vastenshare1"
#nfs_zone = "us-central1-a"
#nfs_capacity =1024
filestore_host = "52.1.91.212"
filestore_path = "/home/ec2-user/test"
nfs_external =true
NAT_instance_ip = "35.197.53.217"

#
# Input Data Storage
#
#inputdata_cloud=""
#inputdata_host=""
#inputdata_capacity=""
#inputdata_mountpoint=""

