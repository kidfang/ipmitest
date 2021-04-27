
result_output=$1        # /home/smbuser
CUDA_path=$2            # /root/NVIDIA_CUDA-10.1_Samples
rvs_path=$result_output/ROCmValidationSuite
rocm_path=/opt/rocm/bin

echo -e "\nPlease input the test type (nv_set_tool/rvs_set_tool/rocm_install/nv_basic/amd_basic/nv_p2p/nv_bw/rvs_p2p/rvs_smqt/rvs_iet/rvs_gst): "
read test_type

# nv_set_tool  => Install NVidia GPU test tool only for RHEL based OS
# rvs_set_tool => Install rvs only for ubuntu
# rocm_install => Install rocm only for ubuntu

NV_Install_tool()

{

git clone https://github.com/wilicc/gpu-burn.git
##git clone https://github.com/tbennun/mgbench.git

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

ROCm_install()

{

sudo apt update
sudo apt dist-upgrade
sudo apt install libnuma-dev

read -n 1 -p "Please type ctrl + alt + delete to reboot system, if you already reboot before please press Enter to continue the installer ..."

# wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | sudo apt-key add -
# echo 'deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list

wget -qO - http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key | sudo apt-key add -
sudo sh -c 'echo deb [arch=amd64] http://repo.radeon.com/rocm/apt/debian/ xenial main > /etc/apt/sources.list.d/rocm.list'
sudo apt-get update
sudo apt-get install rocm-dkms rocm-opencl rocm-opencl-dev opencl-headers build-essential cxlactivitylogger libunwind-dev rocblas rocm_bandwidth_test cmake libpci3 libpci-dev doxygen git -y

read -n 1 -p "Please type ctrl + alt + delete to reboot system"

}

nv_basic_info()

{

mkdir $result_output/Basic_info

nvidia-smi | tee $result_output/Basic_info/nvidia_smi.txt
nvidia-smi -a | tee $result_output/Basic_info/nvidia_smi_a.txt
nvidia-smi -q | tee $result_output/Basic_info/nvidia_smi_q.txt
nvidia-smi -q | grep -i vbios | tee $result_output/Basic_info/nvidia_smi_vbios.txt

nvidia-smi -q | grep -i "GPU 00000000:" | tee -a $result_output/Basic_info/GPU_SN_mapping.txt
nvidia-smi -q | grep -i "Serial" | tee -a $result_output/Basic_info/GPU_SN_mapping.txt

lshw -c memory -short | tee  $result_output/Basic_info/mem_info.txt
dmidecode -t memory | tee $result_output/Basic_info/mem.txt
dmidecode -t bios | tee $result_output/Basic_info/bios.txt
lspci | grep -i NVIDIA | tee $result_output/Basic_info/nvidia_gpu_pcie.txt
lspci -tv | tee $result_output/Basic_info/lspci_tv.txt
lscpu | tee $result_output/Basic_info/lscpu.txt

lspci -vvvd 10de: | tee $result_output/Basic_info/lspci_10ee.txt
lspci | tee $result_output/Basic_info/lspci.txt
lspci -vvv | tee $result_output/Basic_info/lspci_vvv.txt

}

amd_basic_info()

{

mkdir $result_output/Basic_info

$rocm_path/rocm-smi | tee $result_output/Basic_info/rocm_smi.txt
$rocm_path/rocm-smi -a | tee $result_output/Basic_info/rocm_smi_a.txt
$rocm_path/rocm-smi -v | tee $result_output/Basic_info/rocm_smi_v.txt
$rocm_path/rocminfo | tee $result_output/Basic_info/rocminfo.txt
/opt/rocm/opencl/bin/x86_64/clinfo | tee $result_output/Basic_info/clinfo.txt

lshw -c memory -short | tee $result_output/Basic_info/mem_info.log
dmidecode -t memory | tee $result_output/Basic_info/mem.log
dmidecode -t bios | tee $result_output/Basic_info/bios.log
lspci | grep -F [AMD/ATI] | tee $result_output/Basic_info/amd_gpu_pcie.log
lspci -tv | tee $result_output/Basic_info/lspci_tv.log
lscpu | tee $result_output/Basic_info/lscpu.log
dmesg | egrep -i "error|fail|fatal|warn|wrong|bug|fault^default" | tee $result_output/Basic_info/dmesg.txt
dmesg | tee $result_output/Basic_info/dmesg_all.txt

}

nv_p2p_test()

{

$CUDA_path/1_Utilities/p2pBandwidthLatencyTest/p2pBandwidthLatencyTest | tee $result_output/p2p.log

}

nv_bw_test()

{

GPU_num=$( nvidia-smi -q | grep -i vbios | wc -l )

for (( i=0; i<$GPU_num; i=i+1 ));
  do
  $CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=$i | tee -a $result_output/GPU_bw_all.txt 
  done
  
$CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=all | tee $result_output/GPU_bw_all_onetime.txt 

}

nv_bw_all_test()

{

GPU_num=$( nvidia-smi -q | grep -i vbios | wc -l )

for (( i=0; i<$GPU_num; i=i+1 ));
  do
  $CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=$i | tee -a $result_output/GPU_bw_all.txt &
  done 

}

rvs_p2p_test()

{

$rocm_path/rocm_bandwidth_test | tee $result_output/amd_p2p.log

}

rvs_smqt()

{

$rvs_path/build/bin/rvs -d 5 -c $rvs_path/build/bin/conf/smqt_3.conf | tee $result_output/smqt3.txt

}

rvs_iet()

{

$rvs_path/build/bin/rvs -d 5 -c $rvs_path/build/bin/conf/iet_6.conf | tee $result_output/iet6.txt

}

rvs_gst()

{

$rvs_path/build/bin/rvs -d 5 -c $rvs_path/build/bin/conf/qst_7.conf 

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
	"rocm_install")
		echo "Start to set and install AMD ROCm ... "
		ROCm_install 1
		;;
	"nv_p2p")
		echo "Start to test nvidia p2p ... "
		nv_p2p_test 1
		;;
	"nv_bw")
		echo "Start to test nvidia bw ... "
		nv_bw_test 1
		;;
	"nv_bw_all")
		echo "Start to test nvidia bw all ... "
		nv_bw_all_test 1
		;;
	"nv_basic")
		echo "Start to save the basic information ... "
		nv_basic_info 1
		;;
	"amd_basic")
		echo "Start to save the basic information ... "
		amd_basic_info 1
		;;
	"rvs_p2p")
		echo "Start to test AMD GPU p2p ... "
		rvs_p2p_test 1
		;;
	"rvs_smqt")
		echo "Start to test AMD GPU SMBIOS Mapping Test ... "
		rvs_smqt 1
		;;
	"rvs_iet")
		echo "Start to test AMD GPU InputEDPp Test 2hrs ... "
		rvs_iet 1
		;;
	"rvs_gst")
		echo "Start to test AMD GPU Stress Test 12hrs ... "
		rvs_gst 1
		;;
	*)
		echo "End~~~~"
		exit 0
		;;
esac
