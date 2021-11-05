#!/bin/bash
#!/bin/sh

result_output=$('pwd')

mkdir $result_output/Basic_info >/dev/null 2>&1

lshw -c memory -short | tee  $result_output/Basic_info/mem_info.txt
dmidecode -t memory | tee $result_output/Basic_info/mem.txt
dmidecode -t bios | tee $result_output/Basic_info/bios.txt

lspci | grep -i Qualcomm | tee $result_output/Basic_info/qualcomm_AI_pcie.txt
lspci -tv | tee $result_output/Basic_info/lspci_tv.txt
lspci -vvvd 17cb: | tee $result_output/Basic_info/lspci_17cb.txt
lspci | tee $result_output/Basic_info/lspci.txt
lspci -vvv | tee $result_output/Basic_info/lspci_vvv.txt
lscpu | tee $result_output/Basic_info/lscpu.txt

ipmitool mc info | tee $result_output/Basic_info/ipmitool_mc_info.txt
ipmitool sdr list | tee $result_output/Basic_info/ipmitool_sdr_list.txt

ls -l /sys/bus/mhi/devices/mhi* | tee $result_output/Basic_info/mhi_path.txt
sensors | tee $result_output/Basic_info/sensors.txt
/opt/qti-aic/tools/qaic-util -q | tee $result_output/Basic_info/qaic-util_q.txt
modinfo qaic | tee $result_output/Basic_info/qaic_modinfo.txt

$result_output/speed_numa_check_all.sh a |  tee $result_output/Basic_info/speed_numa.txt

