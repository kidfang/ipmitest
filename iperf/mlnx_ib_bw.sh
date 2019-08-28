#For 2port ib lan card

test_mode=$1  #SOP or RDMA
test_sut=$2   #RX or TX
test_vid=$3   #Ex. mlx5
test_numa=$4  #Numa node
test_ip=$5    #RX_ip
cpu_core=$6   #cpu core

if [ $test_mode = SOP ]; then

  if [ $test_sut = RX ]; then
    #RX
    taskset -c $cpu_core ib_write_bw -a -b -d "$test_vid"_0 --report_gbits -p 18516 & taskset -c $cpu_core ib_write_bw -a -b -d "$test_vid"_1 --report_gbits -p 18517
  else
    #TX
    taskset -c $cpu_core ib_write_bw -a -b -d "$test_vid"_0 --report_gbits $test_ip -p 18516 & taskset -c $cpu_core ib_write_bw -a -b -d "$test_vid"_1 --report_gbits $test_ip -p 18517
  fi
  
else
  
  if [ $test_sut = RX ]; then
    #RX
    numactl -N $test_numa -l ib_read_bw -t 256 -b -d "$test_vid"_0 -D 66 --report_gbits --cpu_util -p 18516 & numactl -N $test_numa -l ib_read_bw -t 256 -b -d "$test_vid"_1 -D 66 --report_gbits --cpu_util -p 18517
  else
    #TX
    numactl -N $test_numa -l ib_read_bw -t 256 -b -d "$test_vid"_0 -D 66 --report_gbits --cpu_util $test_ip -p 18516 & numactl -N $test_numa -l ib_read_bw -t 256 -b -d "$test_vid"_1 -D 66 --report_gbits --cpu_util $test_ip -p 18517
  fi
  
fi
