mkdir /home/test/Stress_result_gpuburn >/dev/null 2>&1
mkdir /home/test/Stress_result_stress-ng >/dev/null 2>&1

for (( i=1; i<=10; i=i+1 ));
 	do
		cd /home/test/gpu-burn
		./gpu_burn 300 | tee /home/test/Stress_result_gpuburn/gpuburn_test_"$i".log & stress-ng --cpu `nproc` --vm `nproc` --vm-bytes 90% --io `nproc` --hdd `nproc` --hdd-bytes 1g --timeout 300 2>&1 | tee /home/test/Stress_result_stress-ng/stress_ng_test_"$i".log
		sleep 20
		date | tee -a /home/test/Stress_result_gpuburn/gpuburn_test_"$i".log
                date | tee -a /home/test/Stress_result_stress-ng/stress_ng_test_"$i".log
 	done
