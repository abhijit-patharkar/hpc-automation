#!/bin/bash
cd /usr/app/codebase/vasten-terraform/ext_mount_module
#cd ~/Music/basic
terraform init
terraform workspace select $2 || terraform workspace new $2
terraform apply -auto-approve -input=false -lock=false --var-file=/usr/app/codebase/vasten-terraform/vars/$1 >> /home/$2/logs.txt
