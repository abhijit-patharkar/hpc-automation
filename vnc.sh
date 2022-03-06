#!/bin/bash
ssh -i /home/$2/.ssh/id_rsa $2@$1 "sudo su - scriptvast3 -c 'sh /home/scriptvast3/password.sh $3 '" > /home/$2/vnclog
