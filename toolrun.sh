#!/bin/bash
#ssh scriptvast3@$1 "sudo su - scriptvast3 -c 'Vsimuladen -np $2 -host $3 /home/test/$4'"
#ssh -i /home/$2/.ssh/id_rsa $2@$1 "sudo su - scriptvast3 -c 'Vsimuladen -np $3 -host $4 /home/test/$5'" > /home/$2/netlist_output.txt
ssh -i /home/$2/.ssh/id_rsa $2@$1 "sudo su - scriptvast3 -c 'sh /home/scriptvast3/run.sh $3 $4 $5 $6'" > /home/$2/netlist_output.txt &

