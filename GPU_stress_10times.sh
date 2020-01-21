mkdir /home/test/Stress_result_gpuburn >/dev/null 2>&1
mkdir /home/test/Stress_result_stress-ng >/dev/null 2>&1

run_time=300
test_time=10

ipmi()
{

sleep 150

echo -e "Start test 150 sec :   \c" | tee -a /home/test/Power_recording.log
ipmitool sdr list | grep -i watt | tee -a /home/test/Power_recording.log

sleep 150

}

for (( i=1; i<=$test_time; i=i+1 ));
        do
                cd /home/test/gpu-burn
		echo -e "\n----------\n" | tee -a /home/test/Power_recording.log
		echo -e "Test $i" | tee -a /home/test/Power_recording.log

		echo -e "Start test 0   sec :   \c" | tee -a /home/test/Power_recording.log
		ipmitool sdr list | grep -i watt | tee -a /home/test/Power_recording.log

                ./gpu_burn $run_time | tee /home/test/Stress_result_gpuburn/gpuburn_test_"$i".log & stress-ng --cpu `nproc` --vm `nproc` --vm-bytes 90% --io `nproc` --hdd `nproc` --hdd-bytes 1g --timeout $run_time 2>&1 | tee /home/test/Stress_result_stress-ng/stress_ng_test_"$i".log & ipmi $i

		sleep 35

		date | tee -a /home/test/Stress_result_gpuburn/gpuburn_test_"$i".log
                date | tee -a /home/test/Stress_result_stress-ng/stress_ng_test_"$i".log
        done
