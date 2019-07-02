#!/bin/bash
dhcp_ip=192.168.1.20
static_ip=192.168.1.100
bmc_user=admin
bmc_pass=password
check_time=300

 for ((i=0;i<$check_time;i++)) ;
  do
   echo $i
    if [ $i -eq 0 ];
     then
      ipmitool -I lanplus -U $bmc_user -P $bmc_pass -H $dhcp_ip lan set 1 ipsrc dhcp
      sleep 20
      ping -c 2 $dhcp_ip
       if [ $? -eq 1 ];
        then
         exit 0
       fi
    fi
      ipmitool -I lanplus -U $bmc_user -P $bmc_pass -H $dhcp_ip lan set 1 ipsrc static 
      sleep 20
      ping -c 2 $static_ip
       if [ $? -eq 1 ];
         then
           echo "BMC change to $static_ip can't be reached by IPMITOOL"
           exit 0
       fi
      ipmitool -I lanplus -U $bmc_user -P $bmc_pass -H $static_ip lan set 1 ipsrc dhcp
      sleep 20
      ping -c 2 $dhcp_ip
       if [ $? -eq 1 ];
        then
           echo "BMC change to $dhcp_ip can't be reached by IPMITOOL"
           exit 0
       fi
  done
