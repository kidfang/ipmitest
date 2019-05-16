#!/bin/bash

bmc_ip=$1

while :; do

if [ "$loop"="" ]; then

 for ((i=11;i<18;i++)) ;
  do
 
	ping -q $bmc_ip -I 192.168.50.$i -c 2 > /dev/null 2>&1

	if [ $? -eq 1 ];
         then
           echo "192.168.50.$i => F"
         else
	   echo "192.168.50.$i => P"
        fi

  done
	echo -e "\nPress Enter to continue scan ip or Ctrl + c to skip:"
	read loop

else
	exit 0

fi

 done
