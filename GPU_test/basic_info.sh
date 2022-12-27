result_output=$1        # /home/smbuser

mkdir $result_output/Basic_info

nvidia-smi | tee $result_output/Basic_info/nvidia_smi.txt
nvidia-smi -a | tee $result_output/Basic_info/nvidia_smi_a.txt
nvidia-smi -q | tee $result_output/Basic_info/nvidia_smi_q.txt
nvidia-smi -q | grep -i vbios | tee $result_output/Basic_info/nvidia_smi_vbios.txt
nvidia-smi topo -m | tee $result_output/Basic_info/nvidia_smi_topo.txt

nvidia-smi -q | grep -i "GPU 0000" | tee -a $result_output/Basic_info/GPU_SN_mapping.txt
nvidia-smi -q | grep -i "Serial" | tee -a $result_output/Basic_info/GPU_SN_mapping.txt

lshw -c memory -short | tee  $result_output/Basic_info/mem_info.txt
dmidecode -t memory | tee $result_output/Basic_info/mem.txt
dmidecode -t bios | tee $result_output/Basic_info/bios.txt
lspci | grep -i NVIDIA | tee $result_output/Basic_info/nvidia_gpu_pcie.txt
lspci -tv | tee $result_output/Basic_info/lspci_tv.txt
lscpu | tee $result_output/Basic_info/lscpu.txt

lspci -vvvd 10de: | tee $result_output/Basic_info/lspci_10de.txt
lspci | tee $result_output/Basic_info/lspci.txt
lspci -vvv | tee $result_output/Basic_info/lspci_vvv.txt

ipmitool mc info | tee $result_output/Basic_info/ipmi_mc_info.txt
ipmitool fru print | tee $result_output/Basic_info/ipmi_fru_print.txt
ipmitool sensor list  | tee $result_output/Basic_info/ipmi_sensor_list_idle.txt
ipmitool chassis status | tee $result_output/Basic_info/ipmi_power_restore_policy.txt

numactl -H | tee $result_output/Basic_info/numactl_hardware.txt
