
num=$(lspci | grep -i "Non-Volatile memory controller"|wc -l)


for (( i=1; i<=$num; i=i+1 ));
	do 
		addr=$(lspci | grep -i "Non-Volatile memory controller" | sed -n "$i"p | cut -f 1 -d " ")
		speed_r=$(lspci -vv -s $addr | grep -i lnksta | sed -n 1p | cut -f 1 -d ",")
		speed_w=$(lspci -vv -s $addr | grep -i lnksta | sed -n 1p | cut -f 2 -d ",")
		full=$(lspci | grep -i "Non-Volatile memory controller" | sed -n "$i"p)
		echo "$full , $speed_r , $speed_w"
	done

echo -e "\n---------------------------------------------------------------------------------------------------------------------------------------\n"


for (( i=1; i<=$num; i=i+1 ));
        do
                addr=$(lspci | grep -i "Non-Volatile memory controller" | sed -n "$i"p | cut -f 1 -d " ")
                speed_n=$(lspci -vv -s $addr | grep -i numa)
                full=$(lspci | grep -i "Non-Volatile memory controller" | sed -n "$i"p)
                echo "$full , $speed_n"
        done

echo -e "\n---------------------------------------------------------------------------------------------------------------------------------------\n"
