
eth_a=$1
lan_num=$2

lspci | grep -i eth | tee lspci.txt

mac_add_a=$(ethtool -i $eth_a | grep -i bus-info | cut -f 2 -d " ")

lspci -vv -s $mac_add_a | tee lspci_lan"$lan_num".txt

ethtool $eth_a | tee lan"$lan_num"_info.txt
ethtool -i $eth_a | tee lan"$lan_num"_info_fw.txt

cat lspci_lan* | grep -i lnksta: > lnksta_all.txt


