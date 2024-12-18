sol()

{
bmc_ip=$1
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
              ipmitool -I lanplus -H ${bmc_ip} -U ${bmc_user} -P ${bmc_password} sol set ${sol_test[$k]} ${sol_loop[$n]} 1
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

]
