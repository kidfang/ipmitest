
result_output=$1        # /home/smbuser
CUDA_path=$2            # /root/NVIDIA_CUDA-10.1_Samples

echo -e "\nPlease input the test type (set_tool/basic/p2p/bw): "
read test_type

Install_tool()

{

git clone https://github.com/wilicc/gpu-burn.git
git clone https://github.com/tbennun/mgbench.git

echo "
blacklist nouveau
options nouveau modeset=0 " > /etc/modprobe.d/blacklist-nouveau.conf

dracut -f

echo -e "\n Install completed, plz reboot system"


}

basic_info()

{

nvidia-smi | tee $result_output/nvidia_smi.log
nvidia-smi -a | tee $result_output/nvidia_smi_a.log
nvidia-smi -q | tee $result_output/nvidia_smi_q.log
nvidia-smi -q | grep -i vbios | tee $result_output/nvidia_smi_vbios.log
lshw -c memory -short | tee  $result_output/mem_info.log
dmidecode -t memory | tee $result_output/mem.log
dmidecode -t bios | tee $result_output/bios.log
lspci | grep -i NVIDIA | tee $result_output/nvidia_gpu_pcie.log
lspci -tv | tee $result_output/lspci_tv.log
lscpu | tee $result_output/lscpu.log

}


p2p_test()

{

$CUDA_path/1_Utilities/p2pBandwidthLatencyTest/p2pBandwidthLatencyTest | tee $result_output/p2p.log

}

bw_test()

{

for i in {0..7} ; do $CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=$i >> $result_output/GPU_bw_all.txt ; done

}

case ${test_type} in

	"set_tool")
		echo "Start to set and install tool ... "
		Install_tool 1
		;;
	"p2p")
		echo "Start to test p2p ... "
		p2p_test 1
		;;
	"bw")
		echo "Start to test bw ... "
		bw_test 1
		;;
	"basic")
		echo "Start to save the basic information ... "
		basic_info 1
		;;
	*)
		echo "End~~~~"
		exit 0
		;;
esac
