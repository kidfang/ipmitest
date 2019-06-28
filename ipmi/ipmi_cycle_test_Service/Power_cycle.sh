#!/bin/bash
#gen_device () {
#  rm /root/device_count > /dev/null
#  lsscsi | wc -l >> /root/device_count
#  lspci  | wc -l >> /root/device_count
#  cat /proc/meminfo | awk '/MemTotal:/ {print $2}' >> /root/device_count
#}

modprobe ipmi-si
sleep 1
modprobe ipmi-devintf
sleep 1

  if   [[ ($(cat /root/device_count|sed -n 1p) -eq $(lsscsi | wc -l) && $(cat /root/device_count|sed -n 2p) -eq $(lspci | wc -l) && $(cat /root/device_count|sed -n 3p) -eq $(free -m | awk '/Mem:/ {print $2}') ) ]] 
     then
            date >> /root/power_cycle_log.txt
	echo PASS >>/root/power_cycle_log.txt
    	ipmitool chassis power cycle
     else
	date >> /root/power_cycle_fail.txt
	lsscsi | wc -l >> /root/power_cycle_fail.txt
	lspci  | wc -l >>  /root/power_cycle_fail.txt
	cat /proc/meminfo | awk '/MemTotal:/ {print $2}' >>  /root/power_cycle_fail.txt
	exit 0
  fi
  
    
