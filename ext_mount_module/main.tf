

resource "null_resource" "module_depends_on" {
  count = "${var.nfs_external == true ? 1 : 0}"
  provisioner "remote-exec" {

  		inline = [
      "sudo mkdir /home/mnt",
  		"sudo /bin/mount -t nfs ${var.filestore_host}:${var.filestore_path} /home/mnt",
  		]



#      script = "/home/scriptuit/trtest/bootstrap.sh"
      connection {
        type = "ssh"
        user = var.deployment_id
        host = var.NAT_instance_ip
#        host = "35.202.70.107"
        private_key = "${file("/home/${var.deployment_id}/.ssh/id_rsa")}"
        agent = "false"
      }
  	}
  }


/*
######################################################################
#  We required template to create instance group. Template is basically
# configuration required for instance inside the instance group.
######################################################################
*/

  resource "google_compute_instance_template" "instance_template_ext" {
    count = "${var.nfs_external == true ? 1 : 0}"
    project = var.project
#    allow_stopping_for_update = true
    name_prefix  = "${var.cluster_name}-instance"
    machine_type = "${var.cluster_machine_type}-${var.cluster_machine_cores}"
    region       = var.region
    tags = ["${var.cluster_name}-no-ip"]
    labels = {
      deployment_id = var.deployment_id
    }


    disk {
      source_image = "projects/${var.project}/global/images/${var.tool_name}-${var.tool_version}"
  }

      network_interface {
        network = "${var.cluster_name}-network"
        subnetwork = "${var.cluster_name}-subnetwork-private"

      }

      service_account {
          email = var.service_account

          scopes = ["cloud-platform"]
      }

      metadata = {
          ssh-keys = "scriptvast3:${file("/root/.ssh/id_rsa.pub")}"
        }

      metadata_startup_script = "sudo /bin/sleep 30 && sudo /bin/mkdir /home/mnt  && sudo /bin/mount -t nfs ${var.filestore_host}:${var.filestore_path} /home/mnt && sudo /bin/chmod -R 777 /home/mnt "


  }

  /*
  ######################################################################
  # Managed Instance Group.
  ######################################################################
  */

  resource "google_compute_instance_group_manager" "instance_group_manager_ext" {
    depends_on = [google_compute_instance_template.instance_template_ext ]
    count = "${var.nfs_external == true ? 1 : 0}"
    project = var.project
    name               = "${var.cluster_name}-instance-group"
    base_instance_name = "${var.cluster_name}-instance"
    zone               = var.location
    target_size        = var.cluster_nodes
    version {
    name              = "${var.cluster_name}-version"
    instance_template = google_compute_instance_template.instance_template_ext[count.index].id

    }
  }

  /*
  ######################################################################
  # we need router to route the traffic to our private subnet instances.
  ######################################################################
  */

  resource "google_compute_route" "router_ext" {
    depends_on  = [google_compute_instance_template.instance_template_ext, google_compute_instance_group_manager.instance_group_manager_ext]
    count = "${var.nfs_external == true ? 1 : 0}"
    project = var.project
    name        = "${var.cluster_name}-route"
    dest_range  = "0.0.0.0/0"
    network     = "${var.cluster_name}-network"
    next_hop_instance_zone  =  var.location
    next_hop_instance = "${var.cluster_name}-nat-instance"
    priority    = 800
    tags        = google_compute_instance_template.instance_template_ext[count.index].tags
  }
