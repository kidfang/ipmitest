#!/bin/bash
# IOPS Based on Tom's Issue Sharing ; seq BW is based on YY3

for i in {0..11};
	do

#	x=$(./msecli -L -n /dev/nvme"$i" | grep -i "PCI Path" | cut -f 9 -d " ")
#	x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 8 -d "/")

	p=$(ls -l /sys/block/nvme"$i"n1 | cut -f 14 -d "/")
        if [[ $p = *[!\ ]* ]]; then
                x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 14 -d "/")
        else
                x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 10 -d "/")
        fi

	n=$(lspci -vv -s "$x" | grep -i numa | cut -f 3 -d " ")
	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")
	
#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r	
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

	taskset -c "$c" fio -rw=write -bs=128k -iodepth=128 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=write_"$x"_nvme"$i".txt &
#	sleep 3

#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
#	sleep 3

#	taskset -c "$c" fio -rw=write -bs=128k -iodepth=128  -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=write_"$x"_nvme"$i".txt
#	sleep 3

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
