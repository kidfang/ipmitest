#!/bin/bash
# value to identify the detected data

Result_path=/root/A100/DC_off_on  # Path to save test log
Reboot_time=14400             # Time for your reboot or powercycle test (sec)
scsi_num=1                    # Type "lsscsi | wc -l" to chek your scsi drive number
GPU_kw=NVIDIA                 # Type the keyword ex. NVIDIA, AMD GPU card need change to vega
GPU_num=8                    # Type "lspci | grep -i NVIDIA | wc -l" to chek your GPU detected amount
GPU_N=8                      # Real GPU card number system installed

Test_type=1               # Input 0 for Powercycle, 1 for Reboot test

modprobe nvidia_modeset    # Delete hashtag to Enable for NVIDIA GPU
modprobe nvidia_drm        # Delete hashtag to Enable for NVIDIA GPU
modprobe nvidia            # Delete hashtag to Enable for NVIDIA GPU
nvidia-smi -pm 1           # Delete hashtag to Enable for NVIDIA GPU

j=$( nvidia-smi -a | grep -i vbios | wc -l )             # Delete hashtag to Enable for NVIDIA GPU
#j=$( /opt/rocm/bin/rocm-smi -i | grep -i GPU | wc -l )  # Delete hashtag to Enable for AMD GPU

# Besure as follows command result all 0, before start this test!!!
# dmesg | grep -i corrected | wc -l
# ipmitool sel list | grep -i interrupt | wc -l

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

s=$( ipmitool sel list | grep -i interrupt )
t=$( ipmitool sel list | wc -l )
u=$( dmesg | grep -i corrected | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )
w=$( lspci | grep -i $GPU_kw | wc -l )
x=$( lsscsi | wc -l )
y=$( cat $Result_path/count.txt )
z=$( ls $Result_path | grep count.txt | wc -l )

# NVIDIA GPU Only

if [ $GPU_kw = NVIDIA ]; then

	gn=$( nvidia-smi -L | wc -l )

	for (( i=1; i<=${gn}; i=i+1 ));
		do

		MN=$( nvidia-smi -L | sed -n "$i"p | awk '{print $2}' | cut -f 1 -d ":" )
		MC=$( nvidia-smi -a -i $MN | grep -A 1 "Max Clocks" | grep -i Graphics | awk '{print $3}' )
		MMC=$( nvidia-smi -a -i $MN | grep -A 3 "Max Clocks" | grep -i Memory | awk '{print $3}' )
                nvidia-smi -lmc $MMC -i $MN
		nvidia-smi -lgc $MC -i $MN

		done
else
	echo "Not NVIDIA Card skip this step..."
fi

# Detect the reboot count number

if [ $z -eq 0 ];then
        touch $Result_path/count.txt
        touch $Result_path/rebootrec.txt
        echo 0 > $Result_path/count.txt
        date +%s > $Result_path/start_time.txt
        sleep 5
 
	/root/speed_numa_check_all.sh 1 > $Result_path/speed_org.txt       

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

/root/speed_numa_check_all.sh 1 > $Result_path/speed_test.txt

dd=$( diff "$Result_path"/speed_test.txt "$Result_path"/speed_org.txt | wc -l )

if [ $x -eq $scsi_num ];then
        if [ $w -eq $GPU_num ] && [ $j -eq $GPU_N ];then
                if [ $v -eq 0 ] && [ $u -eq 0 ] && [ $dd -eq 0 ];then

                        date >> $Result_path/rebootrec.txt
                        echo PASS >> $Result_path/rebootrec.txt

                                if [ $During_time -le $Reboot_time ];then
                                        if [ $Test_type -eq 0 ];then
                                                sleep 10
                                                ipmitool chassis power cycle

						sleep 10
						date | tee -a $Result_path/ipmi_crash.txt
						ipmitool 2>&1 | tee -a $Result_path/ipmi_crash.txt
						
						sleep 3	
						init 6
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
					systemctl disable Power_cycle.service
					systemctl stop Power_cycle.service
                                        exit 0
                                fi
		
                else
                        echo $u > $Result_path/OSevent_"$Test_name".txt
                        echo $s > $Result_path/IPMIevent_"$Test_name".txt
                        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                        dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                        ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
			dmesg | grep -i "6.0 Gbps" > $Result_path/dmesg_ata_"$Test_name".txt
			systemctl disable Power_cycle.service
			systemctl stop Power_cycle.service
                        exit 0
                fi
        else
                lsscsi > $Result_path/lsscsi_"$Test_name".txt
                lspci > $Result_path/lspci_list_"$Test_name".txt
                dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_error_"$Test_name".txt
                dmesg > $Result_path/dmesg_error_all_"$Test_name".txt
                ipmitool sel elist > $Result_path/ipmi_eventlog_"$Test_name".txt
		systemctl disable Power_cycle.service
		systemctl stop Power_cycle.service
                exit 0
        fi
else
        echo {Other error or stopped by user}
        dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal.txt
        dmesg > $Result_path/dmesg_"$Test_name"_scsi_num_abnormal_all.txt
        ipmitool sel elist > $Result_path/ipmi_"$Test_name"_scsi_num_abnormal_eventlog.txt
	systemctl disable Power_cycle.service
	systemctl stop Power_cycle.service
        exit 0
fi
