#!/bin/bash
#string = "$2"
#echo "$2"
ssh -i /home/$2/.ssh/id_rsa $2@$1 "sudo su - scriptvast3 -c '$3'" > /home/$2/netlist_output.txt

