#!/bin/bash

#num=8

num=$(nvme list | grep nvme | wc -l)

for (( i=0; i<$num; i=i+1 ));
do

	#Temp=$(nvme smart-log /dev/nvme$i | grep -i temperature | sed -n 1p)
	tmp=$(nvme smart-log /dev/nvme"$i"n1 | grep temperature | awk '{print $3 " " $4}')     #> $Path/"$x"_nvme"$i"n1_smart_log_$1_stress.txt
	Nv_pci=$(ls -l /sys/block/nvme* | grep -i nvme"$i" | sed -n 1p | awk '{print $11}' | cut -f 5 -d "/")
	echo -e "\n $Nv_pci   nvme"$i"n1   $tmp"

done
