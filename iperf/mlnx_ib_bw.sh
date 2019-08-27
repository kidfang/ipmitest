
#RX
taskset -c $cpu_core ib_write_bw -a -b -d mlx5_0 --report_gbits -p 18515

taskset -c $cpu_core ib_write_bw -a -b -d mlx5_1 --report_gbits -p 18516

#TX
taskset -c $cpu_core ib_write_bw -a -b -d mlx5_0 --report_gbits $RX_ip -p 18515

taskset -c $cpu_core ib_write_bw -a -b -d mlx5_1 --report_gbits $RX_ip -p 18516
