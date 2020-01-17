mkdir /home/test/Stress_result_gpuburn >/dev/null 2>&1
mkdir /home/test/Stress_result_stress-ng >/dev/null 2>&1

for (( i=1; i<=10; i=i+1 ));
 	do
		/home/test/gpu-burn/gpu_burn 300 | tee /home/test/Stress_result_gpuburn/gpuburn_test_"$i".log
		sleep 10
 	done

for (( j=1; j<=10; j=j+1 ));
        do
		stress-ng --cpu `nproc` --vm `nproc` --vm-bytes 90% --io `nproc` --hdd `nproc` --hdd-bytes 1g --timeout 300 | tee /home/test/Stress_result_stress-ng/stress_ng_test_"$i".log
		sleep 10
        done

