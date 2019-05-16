# 2019/04/22 Version 0.1 written by Kid.Fang
# 2019/05/09 Version 0.2 Fix the file name written by Kid.Fang
bmcip=$1

SUT_name=$(ipmitool -I lanplus -H ${bmcip} -U admin -P password fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmcip}"

num=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus sdr elist all | awk '{print $7}' | cut -f 1 -d "." | wc -l)

for (( i=1; i<=$num; i=i+1 ));
	do	
		echo -e "\nTest $i/$num \n"
		sensor=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus sdr elist all | sed -n "$i"p)
		entity=$(ipmitool -H ${bmcip} -U admin -P password -I lanplus sdr elist all | awk '{print $7}' | cut -f 1 -d "." | sed -n "$i"p)
		DtoH=$(echo "ibase=10;obase=16;$entity"|bc)
		echo "$sensor" >> "$SUT_name"_ipmi_sdr_entity_"$entity"_SDR_table_"$DtoH".txt
	done

ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list compact > "$SUT_name"_sdr_list_compact_Type02.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list event > "$SUT_name"_sdr_list_event_Type03.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list mcloc > "$SUT_name"_sdr_list_mcloc_Type12.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list fru > "$SUT_name"_sdr_list_fru_Type11.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list generic > "$SUT_name"_sdr_list_generic_Type10.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list full > "$SUT_name"_sdr_list_full_Type01.txt
ipmitool -I lanplus -H ${bmcip} -U admin -P password sdr list all > "$SUT_name"_sdr_list_all_ALLType.txt
