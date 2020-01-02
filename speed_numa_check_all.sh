test_type=$1

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

echo -e "\n---------------------------------------------------------------------------------------------------------------------------------------\n"


for (( i=1; i<=$num; i=i+1 ));
        do
                addr=$(lspci | grep -F "$m" | sed -n "$i"p | cut -f 1 -d " ")
                speed_n=$(lspci -vv -s $addr | grep -F NUMA)
                full=$(lspci | grep -F "$m" | sed -n "$i"p)
                echo "$full , $speed_n"
        done

echo -e "\n---------------------------------------------------------------------------------------------------------------------------------------\n"

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
                check eth
                ;;
        "6")
                echo -e "\n[FPGA Stratix card]\n\n"
                check 0b2b
                ;;
	*)
		echo -e "\nInput what device you want to check\n\nNvidia_GPU=1,\n\nAMD_GPU=2,\n\nCambricon_GPU=3,\n\nNVMe_Device=4,\n\nLan_card=5,\n\nFPGA_Stratix_card=6\n"
		;;
esac
