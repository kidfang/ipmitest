
s260_ip=$1  #3.3.7.1     #3.3.7.1
Client_ip=$2  #3.3.7.4   #3.3.7.4
Client_eth=$3 #enp65s0  #enp133s0
set_type=$4
nvme_n=$5

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

Format ()

{

nvme_dev_num=$(nvme list | grep -i nvme | awk '{print $1}' | wc -l )

for (( i=1; i<=$nvme_dev_num; i=i+1 ));
	do
		nvme_dev=$(nvme list | grep -i nvme | awk '{print $1}' | sed -n "$i"p )
		nvme format $nvme_dev --namespace-id=1 --ses=1

	done

}

case ${set_type} in
	"0")
		Connect
		;;
	"1")
#		nvme list-subsys
		Disconnect $nvme_n
		;;
	"3")
		Format
		;;
	*)
		echo " 
./nqn_connect.sh <s260_ip> <Client_ip> <Client_eth> [set_type] [nvme_n]
		
[set_type]
0 => Connect all S260-NF0 Node NVMe device into Client system
1 => Disconnect NVMe device [nvme_n]
     ex. [nvme_n] => 0, will disconnect slot 0 NVMe device under system
     		  => all, will disconnect all the slot NVMe device under system
3 => Format all the NVMe device whitch client system connect
	     	  "
		;;
esac
