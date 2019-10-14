#!/bin/bash
# value to identify the detected data

modprobe ipmi_si
modprobe ipmi_devintf

sleep 1

s=$( ipmitool sel list | grep -i interrupt )
t=$( ipmitool sel list | wc -l )
u=$( dmesg | grep -i corrected | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )
w=$( lspci | grep NVIDIA | wc -l )
x=$( lsscsi | wc -l )
y=$( cat /root/count.txt )
z=$( ls /root | grep count.txt | wc -l )

# Detect the reboot count number

if [ $z -eq 0 ];then
	echo 0 > /root/count.txt
else
	echo "$y"
	y=$((y+1))
	echo $y > /root/count.txt
fi

# Detect the IPMI is fully logged and cleared

if [ $t -eq 1024 ];then
	ipmitool sel clear
else
	echo "continue"
fi

# the x can detect the SCSI device, which can be used for
# Virtual Media to disable the reboot process
# the w is reflecting the GPU detected amount, be warned with
# the consumer card with HDMI Audio device equipped.
# the u and v is reflecting the OS event & ipmi event for
# monitor the event listed the PCIe Error.
# command to Power Cycle is -> ipmitool chassis power cycle

if [ $x -eq 1 ];then
	if [ $w -eq 8 ];then
		if [ $v -eq 0 ] && [ $u -eq 0 ];then
			date >> /root/rebootrec.txt
			echo PASS >> /root/rebootrec.txt
			ipmitool chassis power cycle
		else
			echo $u > /root/OSevent.txt
			echo $s > /root/IPMIevent.txt
			dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > /root/dmesg_error.txt
			dmesg > /root/dmesg_error_all.txt
			ipmitool sel list > /root/ipmi_eventlog.txt
			exit 0
		fi
	else
		echo $w > /root/GPUcounterr.txt
		lspci | grep -i NVIDIA > GPU_list.txt
		exit 0
	fi
else
	echo {Other error or stopped by user}
	exit 0
fi
