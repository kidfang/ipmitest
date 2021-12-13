#!/bin/bash

Result_path=/home/source/Qualcomm-AI100/Reboot  # Path to save test log, please modify yourself
Reboot_time=43200         # Time for your reboot or powercycle test (sec)
scsi_num=2                # Type "lsscsi | wc -l" to chek your scsi drive number
GPU_num=3                # Type "lspci | grep -i Qualcomm | wc -l" to chek your FPGA detected amount
Test_type=1               # Input 0 for Powercycle, 1 for Reboot test
                
# Besure as follows command result all 0, before start this test!!!
# dmesg | grep -i corrected | wc -l
# ipmitool sel list | grep -i interrupt | wc -l
# Be sure have put speed_numa_check_all.sh under /home/source

###################################################################
########### Please Modify above parameter for your test ###########
###################################################################
###################################################################
###################################################################
###################################################################

modprobe ipmi_si
modprobe ipmi_devintf

sleep 5

mkdir -p $Result_path >/dev/null 2>&1

w=$( lspci | grep -i Qualcomm | wc -l )   
s=$( ipmitool sel list | grep -i interrupt )
t=$( ipmitool sel list | wc -l )
u=$( dmesg | grep -i corrected | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )
x=$( lsscsi | wc -l )
y=$( cat $Result_path/count.txt )
z=$( ls $Result_path | grep count.txt | wc -l )

# Detect the reboot count number

if [ $z -eq 0 ];then
        touch $Result_path/count.txt
        touch $Result_path/rebootrec.txt
        echo 0 > $Result_path/count.txt
        date +%s > $Result_path/start_time.txt
	sleep 5
	/home/source/speed_numa_check_all.sh a > $Result_path/speed_org.txt
	sleep 5
	init 6
else
        echo "$y"
        y=$((y+1))
        echo $y > $Result_path/count.txt
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

Start_time=$(cat $Result_path/start_time.txt)
End_time=$(date +%s)
During_time=$(($End_time-$Start_time))

echo $Start_time
echo $End_time
echo $During_time

if [ $Test_type -eq 0 ];then
        Test_name=powercycle
else
        Test_name=reboot
fi

/home/source/speed_numa_check_all.sh a > $Result_path/speed_test.txt
dd=$( diff "$Result_path"/speed_test.txt "$Result_path"/speed_org.txt | wc -l )

if [ $x -eq $scsi_num ];then
        if [ $w -eq $GPU_num ];then
                if [ $v -eq 0 ] && [ $u -eq 0 ] && [ $dd -eq 0 ] ;then

                        date >> $Result_path/rebootrec.txt
                        echo PASS >> $Result_path/rebootrec.txt

                                if [ $During_time -le $Reboot_time ];then
                                        if [ $Test_type -eq 0 ];then
                                                sleep 10
                                                ipmitool chassis power cycle
                                        else
                                                sleep 10
                                                init 6
                                        fi
                                else
                                        Start_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $Start_time seconds")
                                        End_time_d=$(date +%Y-%m-%d\ %H:%M:%S -d "1970-01-01 UTC $End_time seconds")
                                        echo "Start_time: $Start_time_d" >> $Result_path/rebootrec.txt
                                        echo "End_time: $End_time_d" >> $Result_path/rebootrec.txt
                                        echo "Test time: $During_time sec" >> $Result_path/rebootrec.txt
                                        sleep 10
                                        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_"$Test_name"_done.txt
                                        dmesg > $Result_path/dmesg_"$Test_name"_done_all.txt
                                        ipmitool sel elist > $Result_path/ipmi_"$Test_name"_done_eventlog.txt
                                        exit 0
                                fi

                else
                        echo $u > $Result_path/OSevent_"$Test_name".txt
                        echo $s > $Result_path/IPMIevent_"$Test_name".txt
                        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                        dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                        ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
                        exit 0
                fi
        else
                echo $w > $Result_path/FPGAcounterr_"$Test_name".txt
                lspci | grep -i Qualcomm > $Result_path/FPGA_list_"$Test_name".txt
		dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
                exit 0
        fi
else
        echo {Other error or stopped by user}
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal.txt
        dmesg > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal_all.txt
        ipmitool sel elist > $Result_path/ipmi_"$Test_name"_scsi_num_abnormal_eventlog.txt
        exit 0
fi
