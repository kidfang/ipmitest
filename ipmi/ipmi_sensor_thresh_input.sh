# 2018/12/24 Version 0.1 written by Kid.Fang
# 2018/12/25 Version 0.2 written by Kid.Fang, add ipmitool event log check and save
# ./ipmi_sensor_thresh_input.sh 192.168.10.1 volt/temp/fan P12V

# Will test LNC, LCR, UNC, UCR
# System Status LED Action will be Blink with Orange, Light with Orange, Blink with Orange, Green
# PS. It need input the value yourself

bmc_ip=$1
Type=$2
temp_test=$3
time=10
SUT_name=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password fru | grep -i "Product Name" | cut -f 14 -d " ")

echo "Product name: $SUT_name"
echo "Product BMC ip: $bmc_ip"
echo "Test sensor: $temp_test"
      
UNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Upper Non-Critical" | cut -f 8 -d " " )
UCR=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Upper Critical" | cut -f 12 -d " ")
LNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Lower Non-Critical" | cut -f 8 -d " " )
LCR=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Lower Critical" | cut -f 12 -d " " )

ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test

echo -e "\nTest lower or upper: "
read test_type
				
if [ ${test_type} = lower ]; then
	echo "Test type: ${test_type}"

	echo -e "\nPlease input new Lower Non-Critical (bigger than the reading value smaller than Upper Non-Critical): "
	read LNC_new

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lnc $LNC_new
	echo "Start test Lower Non-Critical, System status LED will Blink with Orange $time sec !"
	sleep $time

	echo -e "\nPlease input new Lower Critical (bigger than the reading value smaller than Lower Non-Critical): "
        read LCR_new

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lcr $LCR_new
	echo "Start test Lower Critical, System status LED will light with Orange $time sec !"
	sleep $time

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test
	read -n 1 -p "Please check the Status LED, if the reaction is correct please press Enter to continue test ..."

	echo "Test complete, set Lower Critical to default setting, System status LED will Blink with Orange $time sec !"
	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lcr $LCR

	sleep $time
	echo "Test complete, set Lower Non-Critical to default setting, System status LED will light with Green"
	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lnc $LNC

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4
	echo -e "\nPress Enter to save the BMC event log or type no to skip: "
        read Event	
	
	if [ "$Event" = "no" ]; then
		echo "Skip to save event"
	elif [ "$Event" = "" ]; then
		ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 >> ipmi_sensor_"$SUT_name"_"$Type"_BMC_log.txt
	fi

elif [ ${test_type} = upper ]; then
	echo "Test type: ${test_type}"

	echo -e "\nPlease input new Upper Non-Critical (smaller than the reading value bigger than Lower Non-Critical): "
        read UNC_new

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test unc $UNC_new
	echo "Start test Upper Non-Critical, System status LED will Blink with Orange $time sec !"
	sleep $time

	echo -e "\nPlease input new Upper Critical (smaller than the reading value bigger than Upper Non-Critical): "
        read UCR_new

	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test ucr $UCR_new
	echo "Start test Upper Critical, System status LED will light with Orange $time sec !"
	sleep $time
	
	ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test
	read -n 1 -p "Please check the Status LED, if the reaction is correct please press Enter to continue test ..."

        echo "Test complete, set Upper Critical to default setting, System status LED will Blink with Orange $time sec !"
        ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test ucr $UCR

        sleep $time
        echo "Test complete, set Upper Non-Critical to default setting, System status LED will light with Green"
        ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test unc $UNC
	ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4
	echo -e "\nPress Enter to save the BMC event log or type no to skip: "
        read Event	
	
	if [ "$Event" = "no" ]; then
		echo "Skip to save event"
	elif [ "$Event" = "" ]; then
		ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 >> ipmi_sensor_"$SUT_name"_"$Type"_BMC_log.txt
	fi

else
	echo "YOU!!!!! Wrong!!!!!!!!!!"
	exit 0
fi
