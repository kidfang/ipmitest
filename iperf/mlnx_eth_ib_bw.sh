eth_a=$1
test_sut=$2     #RX or TX
test_vid=$3     #Ex. mlx5
cpu_core=$4     #cpu core
test_ip_0=$5    #RX_ip_0
test_ip_1=$6    #RX_ip_1

cpupower frequency-set -g performance
#modprobe cpufreq_ondemand
tuned-adm profile latency-performance

mlnx_tune -p HIGH_THROUGHPUT

mac_add_a=$(ethtool -i $eth_a | grep -i bus-info | cut -f 2 -d " ")
setpci -s $mac_add_a 68.w=5957

ifconfig $eth_a mtu 9000

if [ $test_sut = RX ]; then
    #RX
    taskset -c $cpu_core ib_write_bw -d "$test_vid"_0 -F -p 18000 --report_gbits --run_infinitely & taskset -c $cpu_core ib_write_bw -d "$test_vid"_1 -F -p 19000 --report_gbits --run_infinitely
else
    #TX
    taskset -c $cpu_core ib_write_bw -d "$test_vid"_0 -b -F -p 18000 --report_gbits --run_infinitely $test_ip_0 & taskset -c $cpu_core ib_write_bw -d "$test_vid"_1 -b -F -p 19000 --report_gbits --run_infinitely $test_ip_1 
fi
