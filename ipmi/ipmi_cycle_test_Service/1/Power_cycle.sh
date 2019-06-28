#!/bin/bash

stressHDD()
{
	fio -rw=rw -bs=128k -iodepth=32 -runtime=60 -buffered=0 -direct=1 -ioengine=libaio -name=test -filename=/dev/nvme"$1"n1
}

modprobe ipmi_si
sleep 1
modprobe ipmi_devintf
sleep 1

#	ipmitool lan print | grep -i "IP Address" > BMC_lan.txt

	v=$(ipmitool lan print | grep "MAC Address" | cut -c 27-44 )
#	p=$(awk NR==2 BMC_lan.txt | cut -f 17 -d " ")
	x=$(lspci | grep -i Non | wc -l)
	y=$(cat /root/rebootcount_"$v"_test.txt)
	z=$(ls /root | grep count | wc -l)

	if [ $z -eq 0 ]; then
		echo 0 > /root/rebootcount_"$v"_test.txt
		else 
		echo "$y"
		y=$((y+1))
		echo $y > /root/rebootcount_"$v"_test.txt
	fi

	if [ $x -eq 4 ]; then
		sleep 1
		stressHDD 0 & stressHDD 1 & stressHDD 2 & stressHDD 3
		sleep 2	
		date >> /root/rebootrec_"$v"_test.txt
		echo PASS >> /root/rebootrec_"$v"_test.txt
		for i in {0..3}; do nvme smart-log /dev/nvme"$i"n1 | grep -i media ; done > /root/reboot_pass_nvme_info_"$v"_test.txt
		ipmitool chassis power cycle	
	else
		date >> /root/rebootrec_"$v"_fail.txt
		lspci | grep -i Non >> /root/rebootrec_"$v"_fail.txt		
		exit 0		
	fi


