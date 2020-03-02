#!/bin/bash
# IOPS Based on Yandex suggest ; 
# Seq BW is based on test plan, parameter change to Yandex suggest iodepth=32, numjobs=1

for i in {a..f};
	do

	x=$(ls -l /sys/block/sd"$i" | cut -f 9 -d "/")   ## Need check the result is "ata"
#	y=$(ls -l /sys/block/sd"$i" | cut -f 8 -d "/")   ## Need check the result is pci address, for AMD platform
#	n=$(lspci -vv -s "$y" | grep -i numa | cut -f 3 -d " ")  ## For AMD platform
#	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")  ## For AMD platform

	./msecli -X -B -n /dev/sd"$i" -y  # Only for Micron SSD

#	taskset -c "$c" 
	fio -rw=read -bs=128k -iodepth=32 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=1 -filename=/dev/sd$i --output=read_"$x"_sd"$i".txt
	sleep 3

	./msecli -X -B -n /dev/sd"$i" -y 

############################

        read_result=$( cat read_"$x"_sd"$i".txt | grep READ: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
        echo "read_$x   $read_result" >> READ_report_list.txt

############################

#	taskset -c "$c" 
	fio -rw=write -bs=128k -iodepth=32 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=1 -filename=/dev/sd$i --output=write_"$x"_sd"$i".txt
	sleep 3

#	./msecli -X -B -n /dev/sd"$i" -y

############################

        write_result=$( cat write_"$x"_sd"$i".txt | grep WRITE: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
        echo "write_$x   $write_result" >> WRITE_report_list.txt

############################

#	taskset -c "$c" fio -filename=/dev/sd"$i" -rw=randread -name=test -direct=1 -bs=4k -numjobs=1 -buffered=0 -ioengine=libaio -iodepth=32 -group_reporting -norandommap -runtime=180 -loops=1 -output=randr_"$x"_sd"$i".txt
#	sleep 3

#	./msecli -X -B -n /dev/sd"$i" -y

#	taskset -c "$c" fio -filename=/dev/sd"$i" -rw=randwrite -name=test -direct=1 -bs=4k -numjobs=1 -buffered=0 -ioengine=libaio -iodepth=32 -group_reporting -norandommap -runtime=180 -loops=1 -output=randw_"$x"_sd"$i".txt
#	sleep 3
	done
