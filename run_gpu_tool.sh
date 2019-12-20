
result_output=$1        # /home/smbuser
CUDA_path=$2            # /root/NVIDIA_CUDA-10.1_Samples

echo -e "\nPlease input the test type (nv_set_tool/rvs_set_tool/basic/p2p/bw): "
read test_type

# nv_set_tool  => Install NVidia GPU test tool only for RHEL based OS
# rvs_set_tool => Install rvs only for ubuntu

NV_Install_tool()

{

git clone https://github.com/wilicc/gpu-burn.git
git clone https://github.com/tbennun/mgbench.git

echo "
blacklist nouveau
options nouveau modeset=0 " > /etc/modprobe.d/blacklist-nouveau.conf

dracut -f

echo -e "\n Install completed, plz reboot system"

}

RVS_install()

{

sudo apt-get -y update && sudo apt-get install -y libpci3 libpci-dev doxygen unzip cmake git
sudo apt-get install rocblas rocm_smi64

#Note: If rocm_smi64 is already installed but "/opt/rocm/rocm_smi/ path doesn't exist. Do below:
#sudo dpkg -r rocm_smi64 && sudo apt install rocm_smi64

cd $result_output

git clone https://github.com/ROCm-Developer-Tools/ROCmValidationSuite.git

cd ROCmValidationSuite

cmake ./ -B./build
make -C ./build

cd ./build

make package

sudo dpkg -i rocm-validation-suite*.deb

}

basic_info()

{

mkdir $result_output/Basic_info
nvidia-smi | tee $result_output/Basic_info/nvidia_smi.log
nvidia-smi -a | tee $result_output/Basic_info/nvidia_smi_a.log
nvidia-smi -q | tee $result_output/Basic_info/nvidia_smi_q.log
nvidia-smi -q | grep -i vbios | tee $result_output/Basic_info/nvidia_smi_vbios.log
lshw -c memory -short | tee  $result_output/Basic_info/mem_info.log
dmidecode -t memory | tee $result_output/Basic_info/mem.log
dmidecode -t bios | tee $result_output/Basic_info/bios.log
lspci | grep -i NVIDIA | tee $result_output/Basic_info/nvidia_gpu_pcie.log
lspci -tv | tee $result_output/Basic_info/lspci_tv.log
lscpu | tee $result_output/Basic_info/lscpu.log

}

p2p_test()

{

$CUDA_path/1_Utilities/p2pBandwidthLatencyTest/p2pBandwidthLatencyTest | tee $result_output/p2p.log

}

bw_test()

{

GPU_num=$( nvidia-smi -q | grep -i vbios | wc -l )

for (( i=0; i<$GPU_num; i=i+1 ));
  do
  $CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=$i | tee -a $result_output/GPU_bw_all.txt 
  done
  
$CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=all | tee $result_output/GPU_bw_all_onetime.txt 

}

case ${test_type} in

	"nv_set_tool")
		echo "Start to set and install NVidia GPU test tool ... "
		NV_Install_tool 1
		;;
	"rvs_set_tool")
		echo "Start to set and install AMD RVS test tool ... "
		RVS_install 1
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
