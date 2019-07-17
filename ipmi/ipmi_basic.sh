bmcip=$1
bmc_user=admin
bmc_password=password

echo -e "\nPlease input the test type (fru/mc/lan/sol/all): "
read test_type


SUT_name=$(ipmitool -I lanplus -H ${bmcip} -U admin -P password fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmcip}"



SKU_FRU()

{
  for (( i=0; i<=3; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} fru print $i | tee ipmi_$SUT_name_fru"$i".txt
    done
}

mc()

{
  mc_test=( "info 1" "selftest" "getenables" )
  for (( i=0; i<=2; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} mc ${mc_test[$i]} | tee ipmi_$SUT_name_mc_${mc_test[$i]}.txt
    done
}

lan()

{
  lan_test=( "print 1" "set 1 snmp" )
  for (( i=0; i<=1; i=i+1 ));
  	do
      ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} lan ${lan_test[$i]} | tee ipmi_$SUT_name_lan_${lan_test[$i]}.txt
    done
}

sol()

{
bmcip=$1
bmc_user=$2
bmc_password=$3
sol_test=( "set-in-progress" "force-encryption" "force-authentication" "force-authentication" "privilege-level" "character-accumulate-level" "character-send-threshold" "retry-count" "retry-interval" "non-volatile-bit-rate" "volatile-bit-rate" )
set_in_progress=( "set-complete" "set-in-progress" )
encryption=( "true" "false" )  # force-encryption , force-authentication
privilege_level=( "user" "operator" "admin" )
level=( "64" "128" "255" ) # character-accumulate-level , character-send-threshold
retry_count=("0~7")
retry_interval=("0" "128" "255")
bit_rate=( "9.6" "19.2" "38.4" "57.6" "115.2" )   # non-volatile-bit-rate , volatile-bit-rate

  for (( i=1; i<=${#sol_test[@]}; i=i+1 ));
    do
        item=$i
        k=$(( $i - 1 ))
        echo -e "\nStart test ${sol_test[$k]} ($i/10) ... "

        loop()
        {
          sol_loop=( $2 )
          for (( n=0; n<$1; n=n+1 ));
            do
                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol ${sol_test[$k]} ${sol_loop[$n]}
                ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol info 1
                read -n 1 -p "If it is correct by : $i , Press Enter to test next one ... "
            done
        }

        case ${item} in
           1)

           loop ${#set_in_progress[@]} ${set_in_progress[@]}
            ;;
        esac








    done

}


case ${test_type} in
  "fru")
  echo "Start to test SKU/FRU ... "
  SKU_FRU 1
  ;;

  "mc")
  echo "Start to test mc ... "
  mc 1
  ;;

  "lan")
  echo "Start to test lan item ... "
  lan 1
  ;;

  "sol")
  echo "Start to test sol item ... "
  sol $bmcip $bmc_user $bmc_password
  ;;

  "all")
  echo "Start to test all item ... "
  SKU_FRU 1
  mc 1
  lan 1
  sol 1
  ;;

  *)
  echo "???????????????????????????????????????????"
  ;;

esac
