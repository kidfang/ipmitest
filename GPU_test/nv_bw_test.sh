result_output=$1        # /home/smbuser
CUDA_path=$2            # /root/NVIDIA_CUDA-10.1_Samples

GPU_num=$( nvidia-smi -q | grep -i vbios | wc -l )

for (( i=0; i<$GPU_num; i=i+1 ));
  do
  $CUDA_path/1_Utilities/bandwidthTest/bandwidthTest --device=$i | tee -a $result_output/GPU_bw_all.txt 
  done
