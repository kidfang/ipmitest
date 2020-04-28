
s260_ip=3.3.7.1
Client_ip=3.3.7.4
Client_eth=enp133s0

set_type=$1
nvme_n=$2

Connect ()

{

echo "Connecting to the Storage ..."

ifconfig $Client_eth $Client_ip netmask 255.255.255.0 mtu 9000 up
modprobe nvme ; modprobe nvme-rdma ; modprobe nvme_fabrics

nvme_num=$( nvme discover -t rdma -a "$s260_ip" -s 4420 | grep -i subnqn | wc -l )

for (( i=1; i<=$nvme_num; i=i+1 ));
        do
		sub_nqn=$( nvme discover -t rdma -a $s260_ip -s 4420 | grep -i subnqn | sed -n "$i"p | awk '{print $2}' )
		nvme connect -t rdma -n $sub_nqn -a $s260_ip -s 4420 -i 8
	done

nvme list

echo "------------------- "

nvme list-subsys

}


Disconnect ()

{

nvme_i=$1
nvme_num=$( nvme discover -t rdma -a "$s260_ip" -s 4420 | grep -i subnqn | wc -l )

	if [ $nvme_i -ge 0 ] 2>/dev/null ; then 

		sub_nqn=$( nvme discover -t rdma -a $s260_ip -s 4420 | grep -i subnqn | sed -n "$nvme_i"p | awk '{print $2}' )
		nvme disconnect -n $sub_nqn
 
        else 
                
		for (( i=1; i<=$nvme_num; i=i+1 ));
	        do
                	sub_nqn=$( nvme discover -t rdma -a $s260_ip -s 4420 | grep -i subnqn | sed -n "$i"p | awk '{print $2}' )
                	nvme disconnect -n $sub_nqn
        	done

        fi 

nvme list-subsys

}

case ${set_type} in
	"0")
		Connect
		;;
	"1")
#		nvme list-subsys
		Disconnect $nvme_n
		;;
esac
