#!/bin/bash
# IOPS Based on Tom's Issue Sharing ; seq BW is based on YY3
# RHEL 7.6, fio 3.1

for i in {0..5};
	do

#	x=$(./msecli -L -n /dev/nvme"$i" | grep -i "PCI Path" | cut -f 9 -d " ")
	x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 8 -d "/")
	n=$(lspci -vv -s "$x" | grep -i numa | cut -f 3 -d " ")
	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 8 -d " ")
	
#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r	
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

	taskset -c "$c" fio -rw=read -bs=128k -iodepth=128 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=read_"$x"_nvme"$i".txt
#	sleep 3

############################

	read_result=$( cat read_"$x"_nvme"$i".txt | grep READ: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
	echo "read_$x   $read_result" >> READ_report_list.txt

############################

	newfile=`echo read_"$x"_nvme"$i".txt | sed 's/:/_/g'`
	mv read_"$x"_nvme"$i".txt $newfile

############################

#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

	taskset -c "$c" fio -rw=write -bs=128k -iodepth=128  -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=write_"$x"_nvme"$i".txt
	sleep 3

############################

        write_result=$( cat write_"$x"_nvme"$i".txt | grep WRITE: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
        echo "write_$x   $write_result" >> WRITE_report_list.txt

############################

        newfile=`echo write_"$x"_nvme"$i".txt | sed 's/:/_/g'`
        mv write_"$x"_nvme"$i".txt $newfile

############################

#	./msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	./msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

#	taskset -c 4-7,36-39 fio -filename=/dev/nvme"$i"n1 -rw=randread -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread -output=randr_nvme"$i".txt
#	sleep 3

#	./msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	./msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

#	taskset -c 4-7,36-39 fio -filename=/dev/nvme"$i"n1 -rw=randwrite -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread -output=randw_nvme"$i".txt
#	sleep 3
	done
