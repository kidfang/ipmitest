bmcip=$1

SUT_name=$(ipmitool -I lanplus -H ${bmcip} -U admin -P password fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmcip}"

num=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus sdr info | grep -i Record | cut -f 2 -d ":")
next=0

for (( i=1; i<=$num; i=i+1 ));
	do	
		DEX_to_HEX=$(echo "ibase=10;obase=16;$i"|bc)
		check=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus raw 0x0a 0x22)
		check_a=$(echo $check | cut -f 1 -d " ")
		check_b=$(echo $check | cut -f 2 -d " ")

		if [ $next == 0 ]; then
			next=$i
		fi

		SDR_con=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus raw 0x0a 0x23 0x$check_a 0x$check_b 0x$next 0x00 0x00 0xff)

		Record_type=$(echo $SDR_con | cut -f 6 -d " ")
		Sensor_Number=$(echo $SDR_con | cut -f 10 -d " ")
		next=$(echo $SDR_con | cut -f 1 -d " ")

		case ${Record_type} in    # Set the start byte for ID string ASCII transform
				"01")
				Start=51
				;;
                                "02")
                                Start=35
                                ;;
                                "03")
                                Start=20
                                ;;
                                "10")
                                Start=19
                                ;;
                                "11")
                                Start=19
                                ;;
                                "12")
                                Start=19
                                ;;
                                "d0")
                                Start=19
                                ;;
                                *)
                                Start=19
                                ;;
		esac

		Sensor_name_HEX=$(echo $SDR_con | cut -f $Start-100 -d " ")
		Sensor_name_ASCII=$(echo $Sensor_name_HEX | xxd -r -ps)

		echo "$i     $DEX_to_HEX     $next     $Sensor_Number    $Sensor_name_ASCII           Record_type: $Record_type"
	done


#+2
#01 => 49
#02 => 33
#03 => 18
#08 => 
#09 => 
#0A:0F =>
#10 => 17
#11 => 17
#12 => 17
#13 => 
#14 => 
#C0 =>
