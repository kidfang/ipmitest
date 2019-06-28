cat /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/enabled

apt install numactl -y
apt install hugepages -y
apt install linux-tools-common linux-tools-generic -y
apt install gcc-multilib g++-multilib gfortran-multilib -y
apt install python -y

cpupower frequency-set -r -g performance
cpupower frequency-info | grep \"performance\"
