#!/bin/bash
cd /usr/app/codebase/vasten-terraform/ext_mount_module
#cd ~/Music/basic
terraform workspace select $2 || terraform workspace new $2
terraform destroy -auto-approve -input=false -lock=false --var-file=/usr/app/codebase/vasten-terraform/vars/$1
terraform workspace select default
terraform workspace delete $2

cd /usr/app/codebase/vasten-terraform/main-modules
#cd ~/Music/basic
terraform workspace select $2 || terraform workspace new $2
terraform destroy -auto-approve -input=false -lock=false --var-file=/usr/app/codebase/vasten-terraform/vars/$1
terraform workspace select default
terraform workspace delete $2
userdel -r $2

