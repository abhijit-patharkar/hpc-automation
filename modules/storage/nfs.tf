/*resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}*/

/*
resource "null_resource" "module_delay" {
  depends_on = [null_resource.module_depends_on]
#  count = length(null_resource.client_persistent_vol_setup) == 1 ? 1 : 0
  provisioner "local-exec" {
      command = "sleep 120"
    }

}
*/

resource "google_filestore_instance" "instance" {
#  depends_on = [null_resource.module_depends_on]
  count = "${var.nfs_external == false ? 1 : 0}"
  name = "${var.cluster_name}"
  zone = "${var.location}"
  tier = "STANDARD"

  file_shares {
    capacity_gb = var.capacity
    name        = "${var.cluster_name}"
  }

  networks {
    network = "${var.cluster_name}-network"
    modes   = ["MODE_IPV4"]
  }
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    google_filestore_instance.instance
  ]
}



/*
resource "null_resource" "client_persistent_vol_setup" {
  depends_on = [null_resource.module_depends_on]
  count = "${var.nfs_external == true ? 1 : 0}"
  provisioner "local-exec" {
      command = "/bin/sed -e 's/fileserver_name/${var.name}/' -e 's/vasten_share_server_ip/${var.filestore_host}/' -e 's|fileserver_path|${var.filestore_path}|' -e 's/fileserver_name/${var.capacity}/' -e 's/storage_limit/${var.nfs_capacity}/' ../templates/persistent_vol_template.txt > ../templates/persistent_vol.txt"
  }
}


resource "null_resource" "client_delay" {
  depends_on = [null_resource.module_delay, null_resource.client_persistent_vol_setup]
  count = length(null_resource.client_persistent_vol_setup) == 1 ? 1 : 0
  provisioner "local-exec" {
      command = "sleep 120"
    }

}


resource "null_resource" "persistent_vol_setup" {
  depends_on = [google_filestore_instance.instance]
  count = "${var.nfs_external == false ? 1 : 0}"
  provisioner "local-exec" {
      command = "/bin/sed -e 's/fileserver_name/${var.name}/' -e 's|fileserver_path|${var.name}|' -e 's/vasten_share_server_ip/${google_filestore_instance.instance[count.index].networks[0].ip_addresses[0]}/' -e 's/fileserver_name/${var.capacity}/' -e 's/storage_limit/${var.nfs_capacity}/' ../templates/persistent_vol_template.txt > ../templates/persistent_vol.txt"

  }
}


resource "null_resource" "delay" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup]
  count = length(null_resource.persistent_vol_setup) == 1 ? 1 : 0
  provisioner "local-exec" {
      command = "sleep 120"
    }

}


resource "null_resource" "client_persistent_vol" {
#  depends_on = [google_filestore_instance.instance, null_resource.client_persistent_vol_setup, null_resource.client_delay]
  depends_on = [null_resource.module_depends_on, null_resource.client_persistent_vol_setup]
  count = "${var.nfs_external == true ? 1 : 0}"
  provisioner "local-exec" {
    command = "mv ../templates/persistent_vol.txt ../templates/persistent_vol.yaml && kubectl create -f ../templates/persistent_vol.yaml"
  }
}


resource "null_resource" "client_after" {
  depends_on = [google_filestore_instance.instance, null_resource.client_persistent_vol_setup, null_resource.client_persistent_vol]
  count = length(null_resource.client_persistent_vol) == 1 ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 300"
  }
}


resource "null_resource" "persistent_vol" {
  #depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup, null_resource.delay]
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup]
  count = "${var.nfs_external == false ? 1 : 0}"
  provisioner "local-exec" {
    command = "mv ../templates/persistent_vol.txt ../templates/persistent_vol.yaml && kubectl create -f ../templates/persistent_vol.yaml"
  }
}


resource "null_resource" "after" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_setup, null_resource.persistent_vol]
  count = length(null_resource.persistent_vol) == 1 ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 300"
  }
}


resource "null_resource" "client_persistent_vol_claim" {
  #depends_on = [google_filestore_instance.instance, null_resource.client_persistent_vol, null_resource.client_after ]
  depends_on = [null_resource.module_depends_on, null_resource.client_persistent_vol]
  count = "${var.nfs_external == true ? 1 : 0}"
  provisioner "local-exec" {
    command = "/bin/sed -e 's/fileserver_name/${var.name}/' -e 's/capacity/${var.nfs_capacity}/' ../templates/persistent_vol_claim.txt > ../templates/persistent_vol_claim.yaml && kubectl create -f ../templates/persistent_vol_claim.yaml"
  }
}


resource "null_resource" "client_pvc_after" {
  depends_on = [google_filestore_instance.instance, null_resource.client_persistent_vol_claim]
  count = length(null_resource.client_persistent_vol_claim) == 1 ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 300"
  }
}


resource "null_resource" "persistent_vol_claim" {
  #depends_on = [google_filestore_instance.instance, null_resource.persistent_vol, null_resource.after ]
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol ]
  count = "${var.nfs_external == false ? 1 : 0}"
  provisioner "local-exec" {
    command = "/bin/sed -e 's/fileserver_name/${var.name}/' -e 's/capacity/${var.nfs_capacity}/' ../templates/persistent_vol_claim.txt > ../templates/persistent_vol_claim.yaml && kubectl create -f ../templates/persistent_vol_claim.yaml"
  }
}


resource "null_resource" "pvc_after" {
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_claim]
  count = length(null_resource.persistent_vol_claim) == 1 ? 1 : 0
  provisioner "local-exec" {
    command = "sleep 300"
  }
}




resource "null_resource" "client_daemon_template" {
#  depends_on = [google_filestore_instance.instance, null_resource.client_persistent_vol_claim, null_resource.client_pvc_after ]
  depends_on = [null_resource.module_depends_on, null_resource.client_persistent_vol_claim ]

  count = "${var.nfs_external == "true" ? 1 : 0}"
  provisioner "local-exec" {
    command = "/bin/sed -e 's/prefix/${var.prefix}/' -e 's/fileserver/${var.name}/' -e 's|image_latest|gcr.io/${var.project}/${var.tool_name}:${var.tool_version}|' ../templates/deamon.txt > ../templates/daemon_set_with_mnt.yaml"

  }
}

resource "null_resource" "client_daemon_set_with_mnt" {
  depends_on = [null_resource.module_depends_on, null_resource.client_daemon_template]
  count = "${var.nfs_external == "true" ? 1 : 0}"
  provisioner "local-exec" {
    command = "kubectl apply -f ../templates/daemon_set_with_mnt.yaml"
  }
}


resource "null_resource" "daemon_template" {
#  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_claim, null_resource.pvc_after ]
  depends_on = [google_filestore_instance.instance, null_resource.persistent_vol_claim ]
  count = "${var.nfs_external == false ? 1 : 0}"
  provisioner "local-exec" {
    command = "/bin/sed -e 's/prefix/${var.prefix}/' -e 's/fileserver/${var.name}/' -e 's|image_latest|gcr.io/${var.project}/${var.tool_name}:${var.tool_version}|'  ../templates/deamon.txt > ../templates/daemon_set_with_mnt.yaml"

  }
}

resource "null_resource" "daemon_set_with_mnt" {
  depends_on = [google_filestore_instance.instance, null_resource.daemon_template]
  count = "${var.nfs_external == false ? 1 : 0}"
  provisioner "local-exec" {
    command = "kubectl apply -f ../templates/daemon_set_with_mnt.yaml"
  }
}



# Template for initial configuration bash script
data "template_file" "persistent_vol" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/persistent_vol.tpl")}"
  vars = {
    vasten_share_path =  google_filestore_instance.instance.name
    vasten_share_server_ip = google_filestore_instance.instance.networks[0].ip_addresses[0]
  }
}

# Template for initial configuration bash script
data "template_file" "persistent_vol_claim" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/persistent_vol_claim.tpl")}"

}

# Template for initial configuration bash script
data "template_file" "daemon_set" {
  depends_on = [google_filestore_instance.instance]

  template = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/templates/daemon_set_with_mnt.tpl")}"

  vars = {
    VASTEN_IMAGE_NAME = var.image_name
    VASTEN_IMAGE_TAG = var.image_tag
  }

}
resource "null_resource" "mount_nfs"{


  depends_on = [google_filestore_instance.instance]

  provisioner "local-exec" {
    command = "sudo smount ${var.mount_ip}:/vastenshare1 ../mount-point-directory"
  }

}
*/
