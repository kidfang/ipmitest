# 2018/12/05 Version 0.1 written by Kid.Fang
# 2018/12/25 Version 0.2 written by Kid.Fang, Add stop function after test sensor complete; BMC event log check and save
# ./ipmi_sensor_thresh.sh 192.168.10.1 temp/fan/volt

# Will test LNC, LCR, UNC, UCR
# System Status LED Action will be Blink with Orange, Light with Orange, Blink with Orange, Green

bmc_ip=$1
test_type=$2
time=10
SUT_name=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password fru | grep -i "Product Name" | cut -f 14 -d " ")

echo "Product name: $SUT_name"
echo "Product BMC ip: $bmc_ip"
echo "Test type: $test_type"

if [ $test_type = temp ] || [ $test_type = volt ] || [ $test_type = fan ];
	then
		if [ $test_type = temp ]; then
			Unit="degrees"
			f=1
		elif [ $test_type = volt ]; then
			Unit="Volts"
			f=0.005
		else 
			Unit="RPM"
                        f=100
		fi


		ipmitool -I lanplus -H $bmc_ip -U admin -P password sdr list | grep -i $Unit | cut -f 1 -d "|" > /root/ipmi_sensor_"$SUT_name"_"$test_type".txt
		t=$(cat /root/ipmi_sensor_"$SUT_name"_"$test_type".txt | wc -l)
		
		for (( i=1; i<="$t"; i=i+1 ));
			do
				temp_test=$(cat /root/ipmi_sensor_"$SUT_name"_"$test_type".txt | sed -n "$i"p)

				echo "Start to test $temp_test"
				echo "Process ("$i"/"$t") ....."

				UNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Upper Non-Critical" | cut -f 8 -d " " )
				LNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Lower Non-Critical" | cut -f 8 -d " " )
				LCR=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Lower Critical" | cut -f 12 -d " " )
				NOW=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i Reading | cut -f 12 -d " " )
#				LD=$(echo "$LNC-$LCR" | bc)


				if [ $LNC = na ]
					then
						echo "$temp_test Lower Non-Critical is na, Stop test!"
						continue
					else

						
						Set_LNC=$(echo "$NOW+10*$f" | bc)
						echo "Start test Lower Non-Critical, System status LED will Blink with Orange $time sec !"

						ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lnc $Set_LNC
						
						sleep $time

						if [ $LCR = na ]
							then
								echo "$temp_test Lower Critical is na, Stop test! and set Lower Non-Critical to default setting ..."
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lnc $LNC
								continue
							else
#								Set_LCR=$(echo "$Set_LNC-$LD" | bc)
								Set_LCR=$(echo "$Set_LNC-9*$f" | bc)
								echo "Start test Lower Critical, System status LED will light with Orange $time sec !"
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lcr $Set_LCR

								sleep $time

								ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test

								read -n 1 -p "Please check the Status LED, if the reaction is correct please press Enter to continue test ..."

								echo "Test complete, set Lower Critical to default setting, System status LED will Blink with Orange $time sec !"

		                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lcr $LCR

								sleep $time
								echo "Test complete, set Lower Non-Critical to default setting, System status LED will light with Green"
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test lnc $LNC
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 | grep -i $temp_test | grep -i Lower
								
								echo -e "\nPress Enter to save the BMC event log or type no to skip save and test next one: "
        							read Event	
	
								if [ "$Event" = "no" ]; then
									echo "Skip to save event"
								elif [ "$Event" = "" ]; then
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 | grep -i $temp_test | grep -i Lower >> ipmi_sensor_"$SUT_name"_"$test_type"_BMC_log.txt
								echo "Save event log complete ...."
								sleep 2
								fi
						fi
				fi
			done

		read -n 1 -p "Lower Non-Critical and Lower Critical test already completed, Press Enter to continue to test Upper Non-Critical and Upper Critical ..."

                for (( j=1; j<="$t"; j=j+1 ));
                        do
                                temp_test=$(cat /root/ipmi_sensor_"$SUT_name"_"$test_type".txt | sed -n "$j"p)

                                echo "Start to test $temp_test"
				echo "Process ("$j"/"$t") ....."

                                LNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Lower Non-Critical" | cut -f 8 -d " ")
                                UNC=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Upper Non-Critical" | cut -f 8 -d " ")
                                UCR=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i "Upper Critical" | cut -f 12 -d " ")
				NOW=$(ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test | grep -i Reading | cut -f 12 -d " " )
#				UD=$(echo "$UCR-$UNC" | bc)

                                if [ $UNC = na ]
                                        then
                                                echo "$temp_test Upper Non-Critical is na, Stop test!"
                                                continue
                                        else

                                                Set_UNC=$(echo "$NOW-10*$f" | bc)
                                                echo "Start test Upper Non-Critical, System status LED will Blink with Orange $time sec !"

                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test unc $Set_UNC

                                                sleep $time

                                                if [ $UCR = na ]
                                                        then
                                                                echo "$temp_test Upper Critical is na, Stop test! and set Upper Non-Critical to default setting ..."
                                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test unc $UNC
                                                                continue
                                                        else
#                                                               Set_UCR=$(echo "$Set_UNC+$UD" | bc)
								Set_UCR=$(echo "$Set_UNC+1*$f" | bc)
                                                                echo "Start test Upper Critical, System status LED will light with Orange $time sec !"

                                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test ucr $Set_UCR

                                                                sleep $time

								ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor get $temp_test

								read -n 1 -p "Please check the Status LED, if the reaction is correct please press Enter to continue test ..."

                                                                echo "Test complete, set Upper Critical to default setting, System status LED will Blink with Orange $time sec !"

                                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test ucr $UCR

                                                                sleep $time
                                                                echo "Test complete, set Upper Non-Critical to default setting, System status LED will light with Green"
                                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sensor thresh $temp_test unc $UNC
								ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 | grep -i $temp_test | grep -i Upper

                                                                echo -e "\nPress Enter to save the BMC event log or type no to skip save and test next one: "
                                                                read Event

                                                                if [ "$Event" = "no" ]; then
                                                                        echo "Skip to save event"
                                                                elif [ "$Event" = "" ]; then
                                                                ipmitool -I lanplus -H $bmc_ip -U admin -P password sel elist | tail -n 4 | grep -i $temp_test | grep -i Upper >> ipmi_sensor_"$SUT_name"_"$test_type"_BMC_log.txt
								echo "Save event log complete ...."
                                                                sleep 2
                                                                fi


                                                          
                                                fi
                                fi
                        done

	else
		echo "Can not test!"
		exit 0
fi
