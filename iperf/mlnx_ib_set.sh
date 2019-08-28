#Support max 2ports ib lan card

eth_a=$1
ip_a=$2

ifconfig "$eth_a" "$ip_a" up

cpupower frequency-set -g performance
modprobe cpufreq_ondemand
tuned-adm profile latency-performance

mlnx_tune -p HIGH_THROUGHPUT

mac_add_a=$(ethtool -i $eth_a | grep -i bus-info | cut -f 2 -d " ")
setpci -s $mac_add_a 68.w=5957

#lan_num=$(ibv_devinfo | grep -i vendor_part_id | wc -l)
hca_id=$(mst status -v | grep -i $eth_a | awk '{print $4}')
lan_num=$(mst status -v | grep -i $eth_a | awk '{print $4}' | cut -f 2 -d "_")

if [ $lan_num = 0 ]; then

	# ib0 link ready
	/etc/init.d/opensmd start
else
	# ib1 link ready
	port_guid=$(ibstat "$hca_id" | grep -i "Port GUID" | awk '{print $3}'| sed -n '1p')
	opensm -g $port_guid

fi

ibdev2netdev
