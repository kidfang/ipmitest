#!/bin/bash

#num=8

num=$(nvme list | grep nvme | wc -l)

for (( i=0; i<$num; i=i+1 ));
do

	Temp=$(nvme smart-log /dev/nvme$i | grep -i temperature | sed -n 1p)

	echo $Temp
done

