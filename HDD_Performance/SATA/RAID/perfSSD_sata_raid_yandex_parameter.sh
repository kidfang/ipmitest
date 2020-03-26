#!/bin/bash
# IOPS Based on Yandex suggest ; 
# Seq BW is based on test plan, parameter change to Yandex suggest iodepth=32, numjobs=1
# RHEL 7.7, fio-3.7

#for i in {2..4};
for (( i=3; i<=4; i=i+1 ));
	do
	
	unset x
	ac_hdd=$(mdadm --detail /dev/md12"$i" | grep -i  "Active Devices" | awk '{print $4}')
	rd_lev=$(mdadm --detail /dev/md12"$i" | grep -i  "Raid Level" | awk '{print $4}')	

	for (( j=1; j<=$ac_hdd; j=j+1 ));
  		do
		x_e=$(($j-1))
		sd_hdd=$(mdadm --detail /dev/md12"$i" | grep -i /dev/sd | sed -n "$j"p | cut -f 3 -d "/")
		x[$x_e]=$(ls -l /sys/block/"$sd_hdd" | cut -f 8 -d "/")
		done


#	x=$(ls -l /sys/block/sd"$i" | cut -f 8 -d "/")
#	y=$(ls -l /sys/block/sd"$i" | cut -f 7 -d "/")
#	n=$(lspci -vv -s "$y" | grep -i numa | cut -f 3 -d " ")
#	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")


#	taskset -c "$c" 
	fio -rw=read -bs=128k -iodepth=32 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=1 -filename=/dev/md12$i --output=read_"$rd_lev"_"${x[*]}"_md12"$i".txt
	sleep 3

############################

	read_result=$( cat read_"$rd_lev"_"${x[*]}"_md12"$i".txt | grep READ: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
	echo "read_"$rd_lev"_"${x[*]}"     $read_result" >> READ_report_list.txt

	newfile=`echo read_"$rd_lev"_"${x[*]}"_md12"$i".txt | sed 's/ //g'`
	mv read_"$rd_lev"_"${x[*]}"_md12"$i".txt $newfile


############################

#	taskset -c "$c" 
	fio -rw=write -bs=128k -iodepth=32 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=1 -filename=/dev/md12$i --output=write_"$rd_lev"_"${x[*]}"_md12"$i".txt
	sleep 3

############################

        write_result=$( cat write_"$rd_lev"_"${x[*]}"_md12"$i".txt | grep WRITE: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
        echo "write_"$rd_lev"_"${x[*]}"     $write_result" >> WRITE_report_list.txt

	newfile=`echo write_"$rd_lev"_"${x[*]}"_md12"$i".txt | sed 's/ //g'`
	mv write_"$rd_lev"_"${x[*]}"_md12"$i".txt $newfile

############################


	done
