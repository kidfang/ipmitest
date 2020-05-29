#!/bin/bash
# value to identify the detected data

modprobe ipmi_si
modprobe ipmi_devintf

Result_path=/root/ipmitest/NVMeOF/Reboot_client_Node2_config2
Result_name=nvme_Reboot_Connect_disconnect_test_Node2_config2.txt

sleep 30

/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.1.1 3.2.1.4 enp133s0f0 0
/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.2.1 3.2.2.4 enp133s0f1 0
/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.3.1 3.2.3.4 enp65s0 0

n=$(nvme list | grep nvme | wc -l)

if [ $n -eq 12 ];
then
                 date >> $Result_path/$Result_name
                 echo "Reboot client and connection ok" >> $Result_path/$Result_name
else
                 echo "NVMe connect fail"
                 dmesg >> $Result_path/fail_log
                 exit 0
fi

sleep  30

nvme disconnect-all

n2=$(nvme list|grep nvme|wc -l)

if [ $n2 -eq 0 ];
then
                 date >> $Result_path/$Result_name
                 echo "Reboot client and disconnection ok" >> $Result_path/$Result_name
                 dmesg --clear
else
                 echo "NVMe disconnect fail"
                 exit 0
fi

sleep 30

hdd_num=$( lsscsi | wc -l )

if [ $hdd_num -eq 1 ];
then
                echo "Reboot PASS !" >> $Result_path/$Result_name
                init 6
else
                dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_after_reboot.txt
                dmesg > $Result_path/dmesg_a_after_reboot.txt
                ipmitool sel list > $Result_path/ipmi_reboot_done_log.txt
                exit 0
fi
