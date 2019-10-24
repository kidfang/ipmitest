k=$(ls -l /sys/block/nvme9n1 | cut -f 14 -d "/")

if [[ $k = *[!\ ]* ]]; then  #check $k have string or not
        echo "one!"          # $k have string
else
        echo "zero!"         # $k only space
fi
