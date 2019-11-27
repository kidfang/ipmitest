#!/bin/bash

eth=$1

for ((i=11;i<18;i++)) ;
do
	ip address add dev $eth 192.168.50.$i

done
