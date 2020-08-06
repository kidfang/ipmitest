share_fail=10.1.112.111
dedicated=10.1.112.132

ac=admin
pw=password

# 1h: Dedicated LAN => Only mlan
# 2h: Shared NIC LAN => Lan1
# 0h: Default (Failover mode) => Both mlan/lan1

# WebUI default setting to test, check setting is failover mode

date | tee -a ipmi_mode_switch.txt
echo -e "\n\n------" | tee -a ipmi_mode_switch.txt

for ((i=1;i<=9999999999;i=i+1))
do
	ipmitool -H $share_fail -I lanplus -U $ac -P $pw raw 0x2e 0x20 0x0a 0x3c 0 83 1
	sleep 60

	mode_check=$( ipmitool -H $dedicated -I lanplus -U $ac -P $pw raw 0x2e 0x21 0x0a 0x3c 0 83 )
	bmc_ip=$( ipmitool -H $dedicated -I lanplus -U $ac -P $pw lan print 1 | grep -i "IP Address" | awk '{print $4}'| sed -n 2p )
	bmc_mac=$( ipmitool -H $dedicated -I lanplus -U $ac -P $pw lan print 1 | grep -i "MAC Address" | awk '{print $4}')
	echo -e "\nTest $i\n$mode_check\n$bmc_ip\n$bmc_mac\n\n------" | tee -a ipmi_mode_switch.txt
	sleep 5

###################################

        ipmitool -H $dedicated -I lanplus -U $ac -P $pw raw 0x2e 0x20 0x0a 0x3c 0 83 2
        sleep 60

        mode_check=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw raw 0x2e 0x21 0x0a 0x3c 0 83 )
        bmc_ip=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw lan print 1 | grep -i "IP Address" | awk '{print $4}'| sed -n 2p )
        bmc_mac=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw lan print 1 | grep -i "MAC Address" | awk '{print $4}')
        echo -e "\nTest $i\n$mode_check\n$bmc_ip\n$bmc_mac\n\n------" | tee -a ipmi_mode_switch.txt
        sleep 5

###################################

        ipmitool -H $share_fail -I lanplus -U $ac -P $pw raw 0x2e 0x20 0x0a 0x3c 0 83 0
        sleep 60

        mode_check=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw raw 0x2e 0x21 0x0a 0x3c 0 83 )
        bmc_ip=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw lan print 1 | grep -i "IP Address" | awk '{print $4}'| sed -n 2p )
        bmc_mac=$( ipmitool -H $share_fail -I lanplus -U $ac -P $pw lan print 1 | grep -i "MAC Address" | awk '{print $4}')
        echo -e "\nTest $i\n$mode_check\n$bmc_ip\n$bmc_mac\n\n------" | tee -a ipmi_mode_switch.txt
        sleep 5

done

date | tee -a ipmi_mode_switch.txt
