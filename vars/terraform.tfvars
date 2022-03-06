project = "ptbqld"
region = "us-west1"
location = "us-west1-b"
name_prefix = "project"
project_id = "ptbqld"

# Configuration properties for the cloud CLI utility
# Make sure the properties file is properly configured to make sure the Cluster is configured properly


#
# Cloud Provider
#

# Possible values are "GCP", "AZURE", "AWS"
# v0.1 supports only GCP
cloud="GCP"


#
# GCP Configuration
#

# Project name (prefixed to the cloud tags)
# Possible values:
gcp_project="ptbqld"

# The region to setup the cluster in
# Possible values:
gcp_region="us-west1"

# The location to setup the cluster in
# Possible values:
gcp_location="us-west1-b"

# The prefix to tag the cloud resources
# Possible values:
gcp_prefix="project"

# The ID of the project created in GCP for setting up the cloud resources
gcp_projectId="204968005041"

# The path to the key file which has aceess to cloud resources
gcp_keypath="/home/tactile-acolyte-282822-2fa69b6f2dbb.json"


#
# Network Configuration
#

# Primary Network Configuration
network_primary_cidr="10.0.0.0/16"
network_primary_width = 4
network_primary_spacing = 0

# Secondary Network Configuration
network_secondary_cidr="10.1.0.0/16"
network_secondary_width=4
network_secondary_spacing=0

# Network Logs Enabled (Possible values: true/false)
network_logs=true

#
# Operating System
#
os_name="centos"
os_version="7"

#
# Tool Details
#
tool_name="ujmnhy"
tool_version="pqlamz"

#
# Registry
#
#
#
#service_account="XXX"
service_account="XXX"
#
#
#image_repository_name = "gcr.io/${project}/${tool_name}:${tool_version}"
#image_name = "gcr.io/${project}/${tool_name}"
#image_tag = "ioplkj"
#
# Cluster
#
cluster_name="qazxsw"
cluster_nodes=mkoijn
cluster_machine_type="qwecxz"
cluster_machine_cores=poibnm
deployment_id=ozqhbr
#cluster_localStore_capacity=tyunbv

#
# NFS
#
#nfs_name = ""
#nfs_zone = ""
nfs_capacity = yuiklj
filestore_host = "ijnbhu"
filestore_path = "itungf"
nfs_external = "lothxs"
#NAT_instance_ip = "empovy"
vncpassword = "qlpame"


#
# Input Data Storage
#
inputdata_cloud=""
inputdata_host=""
inputdata_capacity=""
inputdata_mountpoint=""
