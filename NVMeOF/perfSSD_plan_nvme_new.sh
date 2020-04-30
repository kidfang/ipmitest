#!/bin/bash
# IOPS Based on Tom's Issue Sharing ; seq BW is based on YY3
# RHEL 7.6, fio 3.1

eth_name=$1
Eth_pci_bus=$( ethtool -i $eth_name | grep -i bus | awk '{print $2}' )

nvme list > nvme_map_list.txt
nvme list-subsys >>  nvme_map_list.txt
ls -l /sys/block/nvme* | grep -i sub >> nvme_map_list.txt

for i in {0..11};
	do

#	x=$(./msecli -L -n /dev/nvme"$i" | grep -i "PCI Path" | cut -f 9 -d " ")
	x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 8 -d "/")
	n=$(lspci -vv -s $Eth_pci_bus | grep -i numa | cut -f 3 -d " ")
	c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")
	
#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r	
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
	sleep 3

	nvme format /dev/nvme"$i"n1 --namespace-id=1 --ses=1 -f

	sleep 3

	taskset -c "$c" fio -rw=read -bs=128k -iodepth=128 -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=read_"$x"_nvme"$i".txt
#	sleep 3

############################

	read_result=$( cat read_"$x"_nvme"$i".txt | grep READ: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
	echo "read_$x   $read_result" >> READ_report_list.txt

############################

#	newfile=`echo read_"$x"_nvme"$i".txt | sed 's/:/_/g'`
#	mv read_"$x"_nvme"$i".txt $newfile

############################

#	msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
	sleep 3

	nvme format /dev/nvme"$i"n1 --namespace-id=1 --ses=1 -f

	sleep 3

	taskset -c "$c" fio -rw=write -bs=128k -iodepth=128  -runtime=180 -buffered=0 -direct=1 -thread -ioengine=libaio -name=test -numjobs=4 -filename=/dev/nvme"$i"n1 --output=write_"$x"_nvme"$i".txt
	sleep 3

############################

        write_result=$( cat write_"$x"_nvme"$i".txt | grep WRITE: | cut -f 1 -d ")" |  cut -f 2 -d "(" )
        echo "write_$x   $write_result" >> WRITE_report_list.txt

############################

#        newfile=`echo write_"$x"_nvme"$i".txt | sed 's/:/_/g'`
#        mv write_"$x"_nvme"$i".txt $newfile

############################

#	./msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	./msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
	sleep 3

	nvme format /dev/nvme"$i"n1 --namespace-id=1 --ses=1 -f

	sleep 3

	taskset -c "$c" fio -filename=/dev/nvme"$i"n1 -rw=randread -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread --output=ranread_"$x"_nvme"$i".txt

############################

        ranread_result=$( cat ranread_"$x"_nvme"$i".txt | grep read: | cut -f 1 -d "," |  cut -f 2 -d "=" )
        echo "ranread_$x   $ranread_result IOPS" >> READ_IOPS_report_list.txt

############################
	


#	taskset -c 4-7,36-39 fio -filename=/dev/nvme"$i"n1 -rw=randread -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread -output=randr_nvme"$i".txt
#	sleep 3

#	./msecli -N -f 1 -n /dev/nvme$i -g 4096 -m 0 -r
#	sleep 3
#	./msecli -N -f 1 -n /dev/nvme$i -g 512 -m 0 -r
	sleep 3

	nvme format /dev/nvme"$i"n1 --namespace-id=1 --ses=1 -f

	sleep 3

	taskset -c "$c" fio -filename=/dev/nvme"$i"n1 -rw=randwrite -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread --output=ranwrite_"$x"_nvme"$i".txt

############################

        ranwrite_result=$( cat ranwrite_"$x"_nvme"$i".txt | grep write: | cut -f 1 -d "," |  cut -f 2 -d "=" )
        echo "ranwrite_$x   $ranwrite_result IOPS" >> WRITE_IOPS_report_list.txt

############################

#	taskset -c 4-7,36-39 fio -filename=/dev/nvme"$i"n1 -rw=randwrite -name=test -direct=1 -bs=4k -size=100G -numjobs=32 -buffered=0 -ioengine=libaio -iodepth=4 -group_reporting -norandommap -runtime=180 -thread -output=randw_nvme"$i".txt
#	sleep 3
	done
