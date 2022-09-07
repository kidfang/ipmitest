#!/bin/bash

Result_path=/root/BMC_Flash_DC_off_on_0905_v13  # Path to save test log

Reboot_time=172800                     # Time for your powercycle test (sec)
t_times=2000                           # Times for BMC FW flash

up_fw=130406                           # BMC FW for Upgrade
dn_fw=130405                           # BMC FW for Downgrade

path=/root/BMC_FW                      # Two BMC FW folder's path
FW_script=bmc_fw_update_linux.sh       # BMC FW Flash Script file name under BMC FW folder
 
######################################

modprobe ipmi_si
modprobe ipmi_devintf

sleep 5

mkdir -p $Result_path >/dev/null 2>&1
y=$( cat $Result_path/count.txt )
z=$( ls $Result_path | grep count.txt | wc -l )
v=$( ipmitool sel list | grep -i interrupt | wc -l )

Test_name=DC_off_on

## Detect the reboot count number

if [ $z -eq 0 ];then
        touch $Result_path/count.txt
        touch $Result_path/rebootrec.txt
        echo 0 > $Result_path/count.txt
        date +%s > $Result_path/start_time.txt
        sleep 5
                
        init 6
else
        echo "$y"
        y=$((y+1))
        echo $y > $Result_path/count.txt
fi

## Check test time

Start_time=$(cat $Result_path/start_time.txt)
End_time=$(date +%s)
During_time=$(($End_time-$Start_time))

echo $Start_time
echo $End_time
echo $During_time

## Check BMC FW

ipmi_fw()
{
now_fw_1s=$( ipmitool mc info | awk '/Firmware Revision/ {print $4}' )
now_fw_2s=$( ipmitool mc info | grep -A 1 "Aux Firmware Rev Info" | sed -n 2p | awk '{print $1}' )
Dex_now_fw_2s_c=$(( $now_fw_2s ))
Dex_now_fw_2s=$(echo $Dex_now_fw_2s_c | awk '{printf("%02d\n",$0)}')

SUT_name=$(ipmitool fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")
}

## Choose different BMC FW for flash

ipmi_fw 1

c_now_fw=$( echo $now_fw_1s$Dex_now_fw_2s | sed -e 's/\.//g' )
echo $c_now_fw

if [ $c_now_fw -eq $up_fw ];then
	flash_fw=$dn_fw
elif [ $c_now_fw -eq $dn_fw ];then
	flash_fw=$up_fw
else
	flash_fw=$dn_fw
fi

FW_path=$path/$flash_fw

echo -e "\nProduct name: $SUT_name"
echo -e "BMC FW NOW: $now_fw_1s.$Dex_now_fw_2s"
echo -e "Update Flash Path: $FW_path\n"
chmod -R 777 $FW_path
echo -e "Start Flash FW script: $FW_script"

if [ $v -eq 0 ];then  ## Check ipmi sel log no interrupt event

	if [ $During_time -le $Reboot_time ] && [ $y -le $t_times  ];then  ## Check test time and times all not reach setting value
                                
	        ## Start Flash BMC FW

        	cd $FW_path 
		sleep 20
		yes n | ./$FW_script 2>&1 > $Result_path/flash_log.txt
		sleep 10

		ipmi_fw 1
		a_now_fw=$( echo $now_fw_1s$Dex_now_fw_2s | sed -e 's/\.//g' )

		while :
		do

		ipmi_fw 1
                a_now_fw=$( echo $now_fw_1s$Dex_now_fw_2s | sed -e 's/\.//g' )

                if [ $flash_fw -eq $a_now_fw ];then
                        echo "GO!"
			break
                else
			echo "rechek!" >> $Result_path/fail_check.txt
			cd $FW_path
	                sleep 20
        	        yes n | ./$FW_script 2>&1 > $Result_path/flash_log.txt
                	sleep 10
			continue
                fi
		done

                ipmi_fw 1
                a_now_fw=$( echo $now_fw_1s$Dex_now_fw_2s | sed -e 's/\.//g' )


		if [ $flash_fw -eq $a_now_fw ];then ## check BMC FW are the same with Update BMC FW

			date >> $Result_path/rebootrec.txt
			echo "PASS" >> $Result_path/rebootrec.txt
                        echo "Update FW $now_fw_1s.$Dex_now_fw_2s Completed" >> $Result_path/rebootrec.txt
			ipmitool sel elist >>  $Result_path/ipmi_sel_check.txt

			sleep 20
                        ipmitool chassis power cycle

			sleep 10
			date | tee -a $Result_path/ipmi_crash.txt
			ipmitool 2>&1 | tee -a $Result_path/ipmi_crash.txt

			sleep 3
			init 6
		else
			date >> $Result_path/rebootrec.txt
                        echo "Update FW $now_fw_1s.$Dex_now_fw_2s FAIL, Stop test" >> $Result_path/rebootrec.txt
			echo "Update FW $flash_fw" >> $Result_path/fail_check.txt
			echo "BMC FW NOW $a_now_fw" >> $Result_path/fail_check.txt
			systemctl disable Power_cycle.service
			systemctl stop Power_cycle.service
			exit 0
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
