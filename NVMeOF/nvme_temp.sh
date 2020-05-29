for i in {0..11};
        do

#       x=$(./msecli -L -n /dev/nvme"$i" | grep -i "PCI Path" | cut -f 9 -d " ")
 #       x=$(ls -l /sys/block/nvme"$i"n1 | cut -f 8 -d "/")
#       n=$(lspci -vv -s $Eth_pci_bus | grep -i numa | cut -f 3 -d " ")
#       c=$(lscpu | grep -i numa | grep -i node"$n" | cut -f 6 -d " ")

        nvme smart-log /dev/nvme"$i"n1 | grep temperature #> $Path/"$x"_nvme"$i"n1_smart_log_$1_stress.txt

        done

