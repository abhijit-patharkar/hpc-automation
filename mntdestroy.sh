#!/bin/bash
cd /home/scriptuit/vastterra/vasten-terraform/ext_mount_module
#cd ~/Music/basic
terraform destroy -auto-approve -input=false -backup=/home/scriptuit/vastterra/vasten-terraform/testmnt.backup -lock=false --var-file=/home/scriptuit/vastterra/vasten-terraform/vars/$1

