eth_a=$1

cpupower frequency-set -g performance
modprobe cpufreq_ondemand
tuned-adm profile latency-performance

mlnx_tune -p HIGH_THROUGHPUT

mac_add_a=$(ethtool -i $eth_a | grep -i bus-info | cut -f 2 -d " ")
setpci -s $mac_add_a 68.w=5957

