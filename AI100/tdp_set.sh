#!/bin/bash

ai100_num=$(ls -l /sys/bus/pci/devices/*/hwmon/hwmon*/power1_max | wc -l)
tdp_num=66000000

for (( i=1; i<=$ai100_num; i=i+1 ));
	do
		ai100_p=$( ls -l /sys/bus/pci/devices/*/hwmon/hwmon*/power1_max | awk '{print $9}' | sed -n "$i"p )
		echo $tdp_num > $ai100_p

		cat $ai100_p
	done


