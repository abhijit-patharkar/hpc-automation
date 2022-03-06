#!/bin/bash
ssh -i /home/$2/.ssh/id_rsa $2@$1 "sudo su - scriptvast3 -c 'sh /home/scriptvast3/vncpwd.sh $3 '"
