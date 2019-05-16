# 2018/12/10 Version 0.1 written by Kid.Fang
# 2018/12/25 Version 0.2 written by Kid.Fang update User_on_off log save, change the input item
# 2019/04/15 Version 0.3 written by Kid.Fang update Check info => # apt-get install bc
# ./ipmi_user_test.sh $bmc_ip $bmc_user $bmc_password

# Can test Set User name, password, enable, disable, Channel setaccess, User priv, Check password, User set password 20 bytes

#echo -e "Please input the SUT BMC IP: "
#read bmc_ip

bmc_ip=$1

#echo -e "\nPlease input the SUT BMC user name: "
#read bmc_user

bmc_user=$2

#echo -e "\nPlease input the SUT BMC user password: "
#read bmc_password

bmc_password=$3

echo -e "\nPlease check system already install the following command!"
echo -e "\n# apt-get install bc\n"

echo -e "\nPlease input the test type (user_name/user_password/enable/disable/channel_set/user_priv/check_password/user_password_20): "
echo -e "Suggest test order => user_name, user_password, enable, disable, enable, channel_set, user_priv, check_password, user_password_20"
read test_type

echo -e "\nTest User ID from ? "
read id_f

echo -e "\nTest User ID to ? "
read id_t

SUT_name=$(ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} fru | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmc_ip}"
echo -e "Test type: ${test_type}\n"

User_name()

{

for (( i=${id_f}; i<=${id_t}; i=i+1 ));
	do
		DEX_to_HEX=$(echo "ibase=10;obase=16;$i"|bc)
		DEX_fix=$(echo $i | awk '{printf("%02d\n",$0)}')
		TENS=${DEX_fix:0:1}
		ONES=${DEX_fix:1:2}

		ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x45 0x$DEX_to_HEX 0x75 0x73 0x65 0x72 0x3$TENS 0x3$ONES 0x00 0x00 00 00 00 00 00 00 00 00

		ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list

		echo -e "\n"
		read -n 1 -p "Check user name are correct or not ..."
	done
}

User_password()

{

for (( i=${id_f}; i<=${id_t}; i=i+1 ));
        do
		DEX_to_HEX=$(echo "ibase=10;obase=16;$i"|bc)
                DEX_fix=$(echo $i | awk '{printf("%02d\n",$0)}')
		TENS=${DEX_fix:0:1}
                ONES=${DEX_fix:1:2}

		user_fix_d=$(( 128 + $i ))
		user_fix_h=$(echo "ibase=10;obase=16;$user_fix_d"|bc)

		case ${1} in
			1)
				echo -e "\nUser ID: $i\nUser name: user$DEX_fix\nUSer password: pass$DEX_fix\n"
                		ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x47 0x$DEX_to_HEX 0x02 0x70 0x61 0x73 0x73 0x3$TENS 0x3$ONES 0x00 0x00 00 00 00 00 00 00 00 00
				read -n 1 -p "Press Enter to next one"
			;;

			2)
		                ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix user list

				echo -e "\n"
		                read -n 1 -p "Can login by User ID: $i with ID/PW = user$DEX_fix/pass$DEX_fix, Press Enter to next one"
			;;

			3)
				echo -e "\nUser ID: $i\nUser name: user$DEX_fix\nUSer password: 01234567890123456789\n"
				ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x47 0x$user_fix_h 0x02 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 
				ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x47 0x$user_fix_h 0x03 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39
				ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P 01234567890123456789 user list

                                echo -e "\n"
                                read -n 1 -p "Can login by User ID: $i with ID/PW = user$DEX_fix/01234567890123456789, Press Enter to next one"
		esac
        done
}


User_on_off()

{

FUN=$1

for (( i=${id_f}; i<=${id_t}; i=i+1 ));
        do
                DEX_to_HEX=$(echo "ibase=10;obase=16;$i"|bc)
                echo -e "\nUser ID: $i\n"
		echo -e "\nUser ID: $i\n" >> /root/User_on_off_$SUT_name.txt

                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x47 0x$DEX_to_HEX 0$FUN 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

		typeset -u CHECK

		CHECK_out=$(ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x44 0x01 0x$DEX_to_HEX)

                CHECK=$(ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} raw 0x06 0x44 0x01 0x$DEX_to_HEX | cut -f 3 -d " ")

		echo "Output => $CHECK_out"
		echo "Output second byte => $CHECK"

		echo "Output => $CHECK_out" >> /root/User_on_off_$SUT_name.txt
		echo "Output second byte => $CHECK" >> /root/User_on_off_$SUT_name.txt

		CHECK_to_BIN=$(echo "ibase=16;obase=2;$CHECK"|bc)

		echo "Transform to BIN => $CHECK_to_BIN"
		echo "Transform to BIN => $CHECK_to_BIN" >> /root/User_on_off_$SUT_name.txt
	
		CHECK_fix=$(echo $CHECK_to_BIN | awk '{printf("%08d\n",$0)}')

		echo "Add 0 if not 8bit => $CHECK_fix" 
		echo "Add 0 if not 8bit => $CHECK_fix" >> /root/User_on_off_$SUT_name.txt

		GET_CHECK=${CHECK_fix:0:2}
		echo -e "Check bit7 and bit6 => $GET_CHECK\n"
		echo -e "Check bit7 and bit6 => $GET_CHECK\n" >> /root/User_on_off_$SUT_name.txt

		if [ $GET_CHECK = 01 ]; then
			echo -e "User ID: $i => Enable\n"
			echo -e "User ID: $i => Enable\n" >> /root/User_on_off_$SUT_name.txt
			read -n 1 -p "If it is correct by User ID: $i , Press Enter to test next one ... "	

		elif [ $GET_CHECK = 10 ]; then
			echo -e "User ID: $i => Disable\n"
			echo -e "User ID: $i => Disable\n" >> /root/User_on_off_$SUT_name.txt
			read -n 1 -p "If it is correct by User ID: $i , Press Enter to test next one ... "

		else 
			echo -e "Wrong result! Please check again!!\n"
                	read -n 1 -p "It is not correct by User ID: $i , Ctrl+C to stop the test!! "        
		fi

        done

}

Channel_set()
{

for (( i=${id_f}; i<=${id_t}; i=i+1 ));
        do
                echo -e "\nUser ID: $i\n"

                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} channel setaccess 1 $i link=on ipmi=on callin=off
                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list

                echo -e "\n"
                read -n 1 -p "Please check User ID: $i Callin => false, Link Auth => true, IPMI Msg => true, Press Enter to next one"

		echo -e "\nUser ID: $i\n"

                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} channel setaccess 1 $i link=off ipmi=off callin=off
                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list

                echo -e "\n"
                read -n 1 -p "Please check User ID: $i Callin => false, Link Auth => false, IPMI Msg => false, Press Enter to next one"

		echo -e "\nUser ID: $i\n"

                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} channel setaccess 1 $i link=on ipmi=on callin=on
                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list

                echo -e "\n"
                read -n 1 -p "Please check User ID: $i Callin => true, Link Auth => true, IPMI Msg => true, Press Enter to next one"

        done

}

User_priv()
{

for (( i=${id_f}; i<=${id_t}; i=i+1 ));
        do
                DEX_fix=$(echo $i | awk '{printf("%02d\n",$0)}')

                for (( j=1; j<=4; j=j+1));
			do
		                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user priv $i $j 1
                		
				case $j in
					1)
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L callback raw 0x06 0x37
						echo -e "\n"
						ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list | grep -i user$DEX_fix
						echo -e "\n"
						read -n 1 -p "Check User ID: $i can be responding System GUID, Press Enter to test next one"
					;;

					2)
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L user chassis status
						echo -e "\n"
                                                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list | grep -i user$DEX_fix 
                                                echo -e "\n"
                                                read -n 1 -p "Check User ID: $i can be responding Chassis Status, Press Enter to test next one"
					;;

					3)
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L operator lan print
						echo -e "\n"
                                                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list | grep -i user$DEX_fix 
                                                echo -e "\n"
                                                read -n 1 -p "Check User ID: $i can be responding lan information, Press Enter to test next one"
					;;

					4)
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L administrator lan set 1 snmp user$DEX_fix
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L operator lan print 1 | grep -i snmp
						echo -e "\n"
                                                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} user list | grep -i user$DEX_fix 
                                                echo -e "\n"
                                                read -n 1 -p "Check User ID: $i can edit snmp to user$DEX_fix, Press Enter to test next one"
						ipmitool -I lanplus -H ${bmc_ip} -U user$DEX_fix -P pass$DEX_fix -L administrator lan set 1 snmp AMI

					;;
				esac
			done
        done

}


case ${test_type} in

	"user_name")
		echo "Start to set User Name ... "
		User_name 1
		;;
	"user_password")
		echo "Start to set User Password ... "
		User_password 1
		;;
	"enable")
		User_on_off 1
		;;
	"disable")
		User_on_off 0
		;;	
	"channel_set")
		Channel_set 1
		;;
	"user_priv")
		User_priv 1
		;;
	"check_password")
		User_password 2
		;;
	"user_password_20")
		User_password 3
		;;
	*)
		echo "End~~~~"
		exit 0
		;;
esac
