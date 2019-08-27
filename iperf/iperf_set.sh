# enp97s0f1
# enp97s0f0

#ip_a=$1

#echo -e "\nType eth device name:\n"
eth_a=$1

systemctl stop firewalld
systemctl disable firewalld

systemctl stop irqbalance
systemctl disable irqbalance

cpupower frequency-set -g performance
modprobe cpufreq_ondemand
tuned-adm profile latency-performance

#ifconfig $eth_a $ip_a up
ifconfig $eth_a mtu 9000

RX_a=$(ethtool -g $eth_a | grep -i RX | awk '{print $2}'| sed -n '1p')
TX_a=$(ethtool -g $eth_a | grep -i TX | awk '{print $2}'| sed -n '1p')

ethtool -G $eth_a rx $RX_a tx $TX_a

mac_add_a=$(ethtool -i $eth_a | grep -i bus-info | cut -f 2 -d " ")
numa_a=$(lspci -vv -s $mac_add_a | grep -i numa | cut -f 3 -d " ")
cpu_a=$(lscpu | grep -i numa | grep -i node$numa_a | cut -f 8 -d " ")

#echo -e "\nDevice: $eth_a, Mac_Address: $mac_add_a, Numa_node: $numa_a, CPU_core: $cpu_a, IP: $ip_a"
echo -e "\nCheck this path have set_irq_affinity_cpulist.sh or this scrip will cannot action!\n"

set_irq_affinity_cpulist.sh $cpu_a $eth_a

echo -e "\nDevice: $eth_a, Mac_Address: $mac_add_a, Numa_node: $numa_a, CPU_core: $cpu_a, IP: $ip_a\n"
ethtool -g $eth_a
