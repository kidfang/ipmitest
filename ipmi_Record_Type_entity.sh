# 2019/04/22 Version 0.1 written by Kid.Fang
# 2019/05/09 Version 0.2 Fix the file name written by Kid.Fang
bmcip=$1
admin=root
password=0penBmc

SUT_name=$(ipmitool -I lanplus -H ${bmcip} -U $admin -P $password fru print 1 | grep -i "Product Name" | cut -f 14 -d " " | sed -n 1p )

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmcip}"

num=$(ipmitool -H ${bmcip} -U $admin -P $password -I lanplus sdr elist | wc -l)

for (( i=1; i<=$num; i=i+1 ));
        do
                echo -e "\nTest $i/$num \n"
                sensor=$(ipmitool -H ${bmcip} -U $admin -P $password -I lanplus sdr elist | cut -f 1 -d "|" | sed -n "$i"p | sed 's/[ \t]*$//g')
                #sensor=$(ipmitool -H ${bmcip} -U $admin -P $password -I lanplus sdr elist | awk '{print $1}'| sed -n "$i"p)
                stype=$(ipmitool -H ${bmcip} -U $admin -P $password -I lanplus sensor get "$sensor" | grep -i "Sensor Type")
                echo -e "$sensor          $stype \n" >> "$SUT_name"_ipmi_sdr_type.txt
        done
