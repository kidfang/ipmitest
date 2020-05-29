#!/bin/bash
# value to identify the detected data

#modprobe ipmi_si
#modprobe ipmi_devintf

Result_path=/root/ipmitest/NVMeOF/PowerCycle_S260_Node2_config2/Powercycle
Result_name=nvme_Powercycle_Connect_disconnect_test_Node2_config2.txt
Result_path_ssh=/root/ipmitest/NVMeOF/PowerCycle_S260_Node1_config1/Powercycle
Result_name_ssh=nvme_Powercycle_Connect_disconnect_node1_config1.txt

S260_BMCip=10.1.112.44
Node1_sship=10.1.112.142

while : ;
do

/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.1.1 3.2.1.4 enp133s0f0 0
/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.2.1 3.2.2.4 enp133s0f1 0
/root/ipmitest/NVMeOF/nqn_connect.sh 3.2.3.1 3.2.3.4 enp65s0 0

ssh root@$Node1_sship "/root/ipmitest/NVMeOF/nqn_connect.sh 3.1.1.1 3.1.1.4 enp133s0 0"
ssh root@$Node1_sship "/root/ipmitest/NVMeOF/nqn_connect.sh 3.1.2.1 3.1.2.4 enp65s0 0"

##################### Node 2 #####################

n=$(nvme list | grep nvme | wc -l)

if [ $n -eq 12 ];
then
                date >> $Result_path/$Result_name
         #       echo "Reboot client and connection ok" >> $Result_path/$Result_name
		 echo "Connection ok" >> $Result_path/$Result_name
else
                echo "Node2 NVMe connect fail"
		f_n=$( ll $Result_path | grep -i Connect_fail | wc -l )
                dmesg >> $Result_path/Connect_fail_log_"$f_n".txt
#                exit 0
fi

##########################################

##################### Node 1 #####################

ssh_n=$( ssh root@$Node1_sship "nvme list | grep nvme | wc -l" )  

if [ $ssh_n -eq 12 ];
then
		 ssh root@$Node1_sship "date >> $Result_path_ssh/$Result_name_ssh"
         #       echo "Reboot client and connection ok" >> $Result_path/$Result_name
                 ssh root@$Node1_sship "echo "Connection ok" >> $Result_path_ssh/$Result_name_ssh"
else
                 echo "Node1 NVMe connect fail"
		 f_ssh_n=$( ssh root@$Node1_sship "ll $Result_path_ssh | grep -i Connect_fail | wc -l" )
                 ssh root@$Node1_sship "dmesg >> $Result_path_ssh/Connect_fail_log_"$f_ssh_n".txt"
#                 exit 0
fi

##########################################

sleep  30

##################### Node 2 #####################

nvme disconnect-all

n2=$(nvme list|grep nvme|wc -l)

if [ $n2 -eq 0 ];
then
                 date >> $Result_path/$Result_name
#                echo "Reboot client and disconnection ok" >> $Result_path/$Result_name
		 echo "Disconnection ok" >> $Result_path/$Result_name
		dmesg --clear
else
                echo "NVMe disconnect fail"
		f_dn=$( ll $Result_path | grep -i Disconnect_fail | wc -l )
		dmesg >> $Result_path/Disconnect_fail_log_"$f_dn".txt
#                exit 0
fi

##########################################

##################### Node 1 #####################

ssh root@$Node1_sship "nvme disconnect-all"

ssh_n2=$( ssh root@$Node1_sship "nvme list | grep nvme | wc -l" )

if [ $ssh_n2 -eq 0 ];
then
		 ssh root@$Node1_sship "date >> $Result_path_ssh/$Result_name_ssh"
    #            echo "Reboot client and disconnection ok" >> $Result_path/$Result_name
                 ssh root@$Node1_sship "echo "Disconnection ok" >> $Result_path_ssh/$Result_name_ssh"
                 ssh root@$Node1_sship "dmesg --clear"
else
                 echo "Node1 NVMe disconnect fail"
		 f_ssh_dn=$( ssh root@$Node1_sship "ll $Result_path_ssh | grep -i Disconnect_fail | wc -l" )
                 ssh root@$Node1_sship "dmesg >> $Result_path_ssh/Disconnect_fail_log_"$f_ssh_dn".txt"
#                 exit 0
fi

##########################################

#ipmitool -H $S260_BMCip -U admin -P password -I lanplus sel list > $Result_path/ipmi_s260.txt

sleep 30

ipmitool -H $S260_BMCip -U admin -P password -I lanplus chassis power cycle
#ipmitool -H $S260_BMCip -U admin -P password -I lanplus chassis power off

#sleep 60

#ipmitool -H $S260_BMCip -U admin -P password -I lanplus chassis power on

sleep 90

done
