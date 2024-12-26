#!/bin/bash

test_type=$1
read_type=$2

check()

{

m=$1

num=$(lspci | grep -F "$m" | wc -l)

for (( i=1; i<=$num; i=i+1 ));
	do 
		addr=$(lspci | grep -F "$m" | sed -n "$i"p | cut -f 1 -d " ")
		speed_r=$(lspci -vv -s $addr | grep -F LnkSta | sed -n 1p | cut -f 1 -d ",")
		speed_w=$(lspci -vv -s $addr | grep -F LnkSta | sed -n 1p | cut -f 2 -d ",")
		full=$(lspci | grep -F "$m" | sed -n "$i"p)
		echo "$full , $speed_r , $speed_w"
	done

echo -e "\n-----\n"


for (( i=1; i<=$num; i=i+1 ));
        do
                addr=$(lspci | grep -F "$m" | sed -n "$i"p | cut -f 1 -d " ")
                speed_n=$(lspci -vv -s $addr | grep -F NUMA)
                full=$(lspci | grep -F "$m" | sed -n "$i"p)
                echo "$full , $speed_n"
        done

echo -e "\n-----\n"

}

case ${test_type} in

	"1")
		echo -e "\n[Nvidia GPU]\n\n"
		check NVIDIA
		;;
	"2")
		echo -e "\n[AMD GPU]\n\n"
                check [AMD/ATI]
		;;
	"3")
                echo -e "\n[Cambricon GPU]\n\n"
                check Multimedia
		;;
	"4")
                echo -e "\n[NVMe Device]\n\n"
                check Non-Volatile
                ;;
        "5")
                echo -e "\n[Lan card]\n\n"
                check Eth
                ;;
        "6")
                echo -e "\n[Intel FPGA Stratix card]\n\n"
                check 0b2b
                ;;
	"7")
        	echo -e "\n[Intel FPGA Arria card]\n\n"
                check 09c4
                ;;
	"8")
                echo -e "\n[Xilinx FPGA card]\n\n"
                check Xilinx
                ;;
	"9")
                echo -e "\n[LSI raid card]\n\n"
                check LSI
                ;;
	"a")
                echo -e "\n[Qualcomm AI card]\n\n"
                check Qualcomm
                ;;
	"b")
                echo -e "\n[Infiniband Lan card]\n\n"
                check Infiniband
                ;;
	"c")
                echo -e "\n[ASMedia M.2/BPB SATA RAID Controller]\n\n"
                check ASMedia
                ;;		
	"d")
                echo -e "\n[Rebellions ATOM AI card RBLN-CA2]\n\n"
                check 1eff:0010
                ;;
	"e")
                echo -e "\n[Grace Hopper/Blackwell GPU Device]\n\n"
                check 3D
                ;;
	"z")
                echo -e "\n[User checking...]\n\n"
                check $2
                ;;
	*)
		echo -e "\nInput what device you want to check\n
			Nvidia_GPU=1,
			
			AMD_GPU=2,
			
			Cambricon_GPU=3,
			
			NVMe_Device=4,
			
			Lan_card=5,
			
			Intel_FPGA_Stratix_card=6,
			
			Intel_FPGA_Arria_card=7,
			
			Xilinx FPGA card=8, 
			
			LSI raid card=9,
			
			Qualcomm AI card=a,
			
			Infiniband Lan card=b,
		
			ASMedia M.2/BPB SATA RAID Controller=c

   			Rebellions ATOM AI card RBLN-CA2=d
		
			"
		;;
esac
