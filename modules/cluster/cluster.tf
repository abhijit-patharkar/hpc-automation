/*
######################################################################
# Dependency across module
######################################################################
*/

resource "null_resource" "module_depends_on2" {
  triggers = {
    value = "${length(var.module_depends_on2)}"
  }
}

/*
######################################################################
# In case of internal NFS we are creating google filestore instance.
# NAT instance will be deployed in the 'public' subnetwork to allow outbound internet access.
######################################################################
*/

resource "google_filestore_instance" "filestore" {
  depends_on = [null_resource.module_depends_on2]
  count = "${var.nfs_external == false ? 1 : 0}"
  project = var.project
  name = "${var.cluster_name}-filestore"
  zone = "${var.location}"
  tier = "STANDARD"
  labels = {
    deployment_id = var.deployment_id
  }


  file_shares {
    capacity_gb = var.capacity
    name        = "${var.cluster_name}"
  }

  networks {
    network = "${var.cluster_name}-network"
    modes   = ["MODE_IPV4"]
  }
}



/*
######################################################################
# Below instance will execute in case of external NFS
######################################################################
*/

resource "google_compute_instance" "NAT_instance_ext" {
  depends_on = [null_resource.module_depends_on2]
  count = "${var.nfs_external == true ? 1 : 0}"
  allow_stopping_for_update = true
  project = var.project
  name         = "${var.cluster_name}-nat-instance"
  machine_type = "${var.cluster_machine_type}-${var.cluster_machine_cores}"
  zone         = var.location
  tags = ["${var.cluster_name}-nat"]

  labels = {
    deployment_id = var.deployment_id
  }

  can_ip_forward = true

  boot_disk {
    initialize_params {
#      image = "debian-9"
      image = "projects/${var.project}/global/images/ubuntu-gui"
    }
  }

  network_interface {
    network = "${var.cluster_name}-network"
    subnetwork = "${var.cluster_name}-subnetwork-public"

    access_config {
       nat_ip = ""
    }

}
service_account {
    email = var.service_account

    scopes = ["cloud-platform"]
}


metadata = {
  ssh-keys = "${var.deployment_id}:${file("/home/${var.deployment_id}/.ssh/id_rsa.pub")}"
  }

  connection {
    type = "ssh"
    user = "${var.deployment_id}"
    host = google_compute_instance.NAT_instance_ext[count.index].network_interface.0.access_config.0.nat_ip
    private_key = "${file("/home/${var.deployment_id}/.ssh/id_rsa")}"
    agent = "false"
  }

  provisioner "file" {
   source      = "/home/${var.deployment_id}/.ssh/id_rsa"
   destination = "/home/${var.deployment_id}/.ssh/id_rsa"
     }




  metadata_startup_script = "sudo /bin/sleep 30 && sudo /bin/mkdir /home/mnt && sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o $(/sbin/ifconfig | head -1 | awk -F: {'print $1'}) -j MASQUERADE && sudo /bin/chmod -R 777 /home/mnt && sudo /bin/chmod 600 /home/${var.deployment_id}/.ssh/id_rsa && sudo su - scriptvast4 -c 'sh /home/scriptvast4/password.sh ${var.vncpassword}'"
#  metadata_startup_script = "sudo /bin/mkdir /home/test && sudo /bin/sleep 30 && sudo /usr/bin/apt-get install nfs-common -y && sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o $(/sbin/ifconfig | head -1 | awk -F: {'print $1'}) -j MASQUERADE && sudo /bin/chmod -R 777 /home/test"

#  metadata_startup_script = "sudo mkdir /home/test && sudo /bin/sleep 30 && sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o $(/sbin/ifconfig | head -1 | awk -F: {'print $1'}) -j MASQUERADE "
#metadata_startup_script = "sudo /bin/mkdir /home/test && sudo /bin/sleep 30 && sudo /bin/mount -t nfs ${var.filestore_host}:${var.filestore_path} /home/test && sudo /bin/chmod -R 777 /home/test "

}

/*
######################################################################
# Below instance will execute in case of insternal NFS
######################################################################
*/

resource "google_compute_instance" "NAT_instance" {
  depends_on = [null_resource.module_depends_on2, google_filestore_instance.filestore]
  count = "${var.nfs_external == false ? 1 : 0}"
  allow_stopping_for_update = true
  project = var.project
  name         = "${var.cluster_name}-nat-instance"
  machine_type = "${var.cluster_machine_type}-${var.cluster_machine_cores}"
  zone         = var.location
  tags = ["${var.cluster_name}-nat"]

  labels = {
    deployment_id = var.deployment_id
  }

  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = "projects/${var.project}/global/images/ubuntu-gui"
    }
  }

  network_interface {
    network = "${var.cluster_name}-network"
    subnetwork = "${var.cluster_name}-subnetwork-public"

    access_config {
       nat_ip = ""
    }

}
service_account {
    email = var.service_account

    scopes = ["cloud-platform"]
}


metadata = {
    ssh-keys = "${var.deployment_id}:${file("/home/${var.deployment_id}/.ssh/id_rsa.pub")}"
  }

  connection {
    type = "ssh"
    user = "${var.deployment_id}"
    host = google_compute_instance.NAT_instance[count.index].network_interface.0.access_config.0.nat_ip
    private_key = "${file("/home/${var.deployment_id}/.ssh/id_rsa")}"
    agent = "false"
  }

  provisioner "file" {
   source      = "/home/${var.deployment_id}/.ssh/id_rsa"
   destination = "/home/${var.deployment_id}/.ssh/id_rsa"
     }



  metadata_startup_script = "sudo /bin/sleep 30 && sudo /bin/mkdir /home/mnt && sudo /bin/mount -t nfs ${google_filestore_instance.filestore[count.index].networks[0].ip_addresses[0]}:/${google_filestore_instance.filestore[count.index].file_shares[0].name} /home/mnt && sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o $(/sbin/ifconfig | head -1 | awk -F: {'print $1'}) -j MASQUERADE && sudo /bin/chmod -R 777 /home/mnt && sudo /bin/chmod 600 /home/${var.deployment_id}/.ssh/id_rsa && sudo su - scriptvast4 -c 'sh /home/scriptvast4/password.sh ${var.vncpassword}'"
#  metadata_startup_script = "sudo /bin/mkdir /home/test && sudo /bin/sleep 30 && sudo sysctl -w net.ipv4.ip_forward=1 && sudo iptables -t nat -A POSTROUTING -o $(/sbin/ifconfig | head -1 | awk -F: {'print $1'}) -j MASQUERADE "

}


/*
######################################################################
#  We required template to create instance group. Template is basically
# configuration required for instance inside the instance group.
######################################################################
*/

resource "google_compute_instance_template" "instance_template" {
  depends_on = [null_resource.module_depends_on2, google_filestore_instance.filestore, google_compute_instance.NAT_instance]
  count = "${var.nfs_external == false ? 1 : 0}"
#  allow_stopping_for_update = true
  project = var.project
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


    metadata_startup_script = "sudo /bin/sleep 30 && sudo /bin/mkdir /home/mnt && sudo /bin/mount -t nfs ${google_filestore_instance.filestore[count.index].networks.0.ip_addresses.0}:/${google_filestore_instance.filestore[count.index].file_shares[0].name} /home/mnt && sudo /bin/chmod -R 777 /home/mnt "


}

/*
######################################################################
# Managed Instance Group.
######################################################################
*/

resource "google_compute_instance_group_manager" "instance_group_manager" {
  depends_on = [null_resource.module_depends_on2, google_compute_instance_template.instance_template, google_compute_instance.NAT_instance]
  count = "${var.nfs_external == false ? 1 : 0}"
  project = var.project
  name               = "${var.cluster_name}-instance-group"
  base_instance_name = "${var.cluster_name}-instance"
  zone               = var.location
  target_size        = var.cluster_nodes
  version {
  name              = "${var.cluster_name}-version"
  instance_template = google_compute_instance_template.instance_template[count.index].id

  }
}

/*
######################################################################
# we need router to route the traffic to our private subnet instances.
######################################################################
*/

resource "google_compute_route" "router" {
  depends_on  = [google_compute_instance.NAT_instance, google_compute_instance_template.instance_template, google_compute_instance_group_manager.instance_group_manager ]
  count = "${var.nfs_external == false ? 1 : 0}"
  project = var.project
  name        = "${var.cluster_name}-route"
  dest_range  = "0.0.0.0/0"
  network     = "${var.cluster_name}-network"
  next_hop_instance_zone  =  var.location
  next_hop_instance = google_compute_instance.NAT_instance[count.index].name
  priority    = 800
  tags        = google_compute_instance_template.instance_template[count.index].tags
}
