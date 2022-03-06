#!/bin/bash
useradd -m $2
mkdir /home/$2/.ssh
ssh-keygen -t rsa -N "" -f /home/$2/.ssh/id_rsa
cd /usr/app/codebase/vasten-terraform/main-modules
#cd ~/Music/basic
terraform init
terraform workspace select $2 || terraform workspace new $2
terraform apply -auto-approve -input=false  -lock=false --var-file=/usr/app/codebase/vasten-terraform/vars/$1 > /home/$2/logs.txt
#terraform apply -auto-approve -input=false  -lock=false --var-file=/usr/app/codebase/vasten-terraform/vars/$1
#terraform apply --auto-approve=true -lock=false --var-file=../vars/$1 &
#terraform apply --auto-approve=true -lock=false --var-file=./variable_config/terraform.tfvars
