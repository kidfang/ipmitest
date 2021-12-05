result_output=$1        # /home/smbuser

GPU_num=$( nvidia-smi -q | grep -i vbios | wc -l )

for (( i=0; i<$GPU_num; i=i+1 ));
  do
  ./bandwidthTest --device=$i | tee -a $result_output/GPU_bw_all.txt 
  done
