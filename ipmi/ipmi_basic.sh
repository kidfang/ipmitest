bmc_ip=$1
bmc_user=admin
bmc_password=password

echo -e "\nPlease input the test type (fru/mc/lan/sol/channel/all): \n"
read test_type

SUT_name=$(ipmitool -I lanplus -H ${bmc_ip} -U admin -P password fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmc_ip}"

##################################################################################################################

SKU_FRU()

{
  for (( i=0; i<=3; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} fru print $i | tee ipmi_"$SUT_name"_fru"$i".txt
      echo -e "\n----------------------------------------\n"
    done
}

##################################################################################################################

mc()

{
  mc_test=( "info 1" "selftest" "getenables" )
  for (( i=0; i<=2; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} mc ${mc_test[$i]} | tee ipmi_"$SUT_name"_mc_${mc_test[$i]}.txt
      echo -e "\n----------------------------------------\n"
    done
}

##################################################################################################################

lan()

{
  lan_test=( "print 1" "set 1 snmp" )
  for (( i=0; i<=1; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} lan ${lan_test[$i]} | tee ipmi_"$SUT_name"_lan_${lan_test[$i]}.txt
      echo -e "\n----------------------------------------\n"
    done
}

##################################################################################################################

sol()

{
bmc_ip=$1
bmc_user=$2
bmc_password=$3
##sol_test=( "set-in-progress" "force-encryption" "force-authentication" "privilege-level" "character-accumulate-level" "character-send-threshold" "retry-count" "retry-interval" "non-volatile-bit-rate" "volatile-bit-rate" )

set_in_progress=( "set-in-progress" "set-complete" )
encryption=( "true" "false" )  # force-encryption , force-authentication
privilege_level=( "user" "operator" "admin" )
level=( "64" "128" "255" ) # character-accumulate-level , character-send-threshold
##retry_count=("0~7")
retry_interval=("0" "128" "255")
bit_rate=( "9.6" "19.2" "38.4" "57.6" "115.2" )   # non-volatile-bit-rate , volatile-bit-rate

for (( i=0; i<${#set_in_progress[@]}; i=i+1 ));
  do
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set set-in-progress ${set_in_progress[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Set in progress' is ${set_in_progress[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
  done

for (( i=0; i<${#encryption[@]}; i=i+1 ));
  do
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set force-encryption ${encryption[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Force Encryption' is ${encryption[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set force-authentication ${encryption[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Force Authentication' is ${encryption[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
 done

for (( i=0; i<${#privilege_level[@]}; i=i+1 ));
  do
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set privilege-level ${privilege_level[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Privilege Level' is ${privilege_level[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
  done

for (( i=0; i<${#level[@]}; i=i+1 ));
  do
    CAL=$(( ${level[$i]} * 5 ))
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set character-accumulate-level ${level[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Character Accumulate Level' is $CAL , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set character-send-threshold ${level[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Character Send Threshold' is ${level[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
  done

for (( i=0; i<8; i=i+1 ));
  do
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set retry_count $i 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Retry Count' is $i , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
  done

for (( i=0; i<${#retry_interval[@]}; i=i+1 ));
  do
    RTI=$(( ${retry_interval[$i]} * 10 ))
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol retry-interval ${retry_interval[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Retry Interval (ms)' is $RTI , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
  done

for (( i=0; i<${#bit_rate[@]}; i=i+1 ));
  do
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set non-volatile-bit-rate ${bit_rate[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Non-Volatile Bit Rate (kbps)' is ${bit_rate[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set volatile-bit-rate ${bit_rate[$i]} 1
    ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
    echo -e "\n----------------------------------------\n"
    read -n 1 -p "Check 'Volatile Bit Rate (kbps)' is ${bit_rate[$i]} , Press Enter to test next one ... "
    echo -e "\n----------------------------------------\n"
 done

}

##################################################################################################################

channel()

{

  channel_info=( "0" "1" "2" "3" "6" "8" "0x0e" "0x0f" )

  for (( i=0; i<${#channel_info[@]}; i=i+1 ));
    do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} channel info ${channel_info[$i]} | tee ipmi_"$SUT_name"_channel_info_${#channel_info[$i]}.txt
      echo -e "\n----------------------------------------\n"
    done

  for (( i=1; i<6; i=i+1 ));
    do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} channel authcap 1 $i
      echo -e "\n----------------------------------------\n"
      read -n 1 -p "Test channel authcap $i Confirm command response without any error , Press Enter to test next one ... "
      echo -e "\n----------------------------------------\n"
    done

}

case ${test_type} in
  "fru")
  echo -e "\nStart to test SKU/FRU ... \n"
  SKU_FRU 1
  ;;

  "mc")
  echo -e "\nStart to test mc ... \n"
  mc 1
  ;;

  "lan")
  echo -e "\nStart to test lan item ... \n"
  lan 1
  ;;

  "sol")
  echo -e "\nStart to test sol item ... \n"
  sol $bmc_ip $bmc_user $bmc_password
  ;;

  "channel")
  echo -e "\nStart to test sol item ... \n"
  channel 1
  ;;

  "all")
  echo -e "\nStart to test all item ... \n"
  SKU_FRU 1
  mc 1
  lan 1
  sol 1
  channel 1
  ;;

  *)
  echo "\n???????????????????????????????????????????\n"
  ;;

esac
