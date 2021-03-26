# 2019/04/11 Version 0.1 written by Kid.fang

bmcip=$1
test_type=$2
sys_num=$3
sys_file=$4

red_user=admin
red_pw=password

#red_user=Administrator
#red_pw=superuser

#$red_user:$red_pw

SUT_name=$(ipmitool -I lanplus -H ${bmcip} -U admin -P password fru print 1 | grep -i "Product Name" | cut -f 14 -d " ")

echo -e "\nProduct name: $SUT_name"
echo "Product BMC ip: ${bmcip}"

#######################################

Reset_Type()
{
echo "Reset_Type: $1"
eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -d '{\"ResetType\":\"$1\"}' -X POST https://$bmcip/redfish/v1/Systems/Self/Actions/ComputerSystem.Reset
}

IndicatorLED()
{
echo "IndicatorLED: $1"
eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -d '{\"IndicatorLED\":\"$1\"}' -X PATCH https://$bmcip/redfish/v1/Systems/Self
}

#######################################

BootSourceOverrideEnabled()
{

bs_e=$1
bs_t=$2
bs_s=$3
bs_m=$4

if [ $bs_e = 1 ]; then
	echo -e "\n-------------------------\n\n[Check BootSource status]\n"
	curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Systems/Self | jq '.Boot.BootSourceOverrideTarget, .Boot.BootSourceOverrideEnabled'
	echo -e "\n-------------------------\n\n"
elif [ $bs_s = 1 ]; then
	echo -e "\n-------------------------\n\nBootSourceOverrideEnabled: $bs_e"
        echo -e "BootSourceOverrideTarget: $bs_t"
	echo -e "BootSourceOverrideMode: $bs_m\n"
	eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -X PATCH -d '{\"Boot\":{\"BootSourceOverrideEnabled\":\"$bs_e\"\,\"BootSourceOverrideMode\":\"$bs_m\"\,\"BootSourceOverrideTarget\":\"$bs_t\"}}' https://$bmcip/redfish/v1/Systems/Self -H  \'If-Match\: \* \' | jq
	echo -e "\n-------------------------\n\n"
else
	echo -e "\n-------------------------\n\nBootSourceOverrideEnabled: $bs_e"
	echo -e "BootSourceOverrideTarget: $bs_t\n"
	eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -X PATCH -d '{\"Boot\":{\"BootSourceOverrideEnabled\":\"$bs_e\"\,\"BootSourceOverrideTarget\":\"$bs_t\"}}' https://$bmcip/redfish/v1/Systems/Self -H  \'If-Match\: \* \' | jq
	echo -e "\n-------------------------\n\n"
fi

}

#######################################

System_info()
{

info_ty=$1
num=$2
info_name=$3

echo -e "\n-------------------------\n\n[Show how many CPU/DIMM/LAN slots or BIOS info on your system]\n"
curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Systems/Self/$info_ty | jq '.' >> 4-2_"$info_name"_and_"$info_name"_ID_"$SUT_name".txt
echo -e "\n-------------------------\n\n" >> 4-2_"$info_name"_and_"$info_name"_ID_"$SUT_name".txt
echo -e "\n[Show each CPU/DIMM/LAN/BIOS information ,DIMM must match your DMI information ,#dmidecode -t 17, CPU/LAN/BIOS match your SPEC]"
echo -e "[This script will save all the output into file '4-2_"$info_name"_and_"$info_name"_ID_"$SUT_name".txt' please check the file yourself]\n"
echo -e "\n-------------------------\n\n"

for (( i=1; i<=$num; i=i+1 ));
	do	
		curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Systems/Self/$info_ty/$i | jq '.' >> 4-2_"$info_ty"_and_"$info_ty"_ID_"$SUT_name".txt
		echo -e "\n-------------------------\n\n" >> 4-2_"$info_ty"_and_"$info_ty"_ID_"$SUT_name".txt
	done
}

#######################################

Chassis_info()
{

info_ty=$1
info_name=$2

if [ $info_ty = 1 ]; then

	echo -e "[This script will clear all LogServices/Logs please check log is empty]\n"
	curl -k -u $red_user:$red_pw -H "content-type:application/json" -X POST -d '{"ClearType":"ClearAll"}' https://$bmcip/redfish/v1/Chassis/Self/LogServices/Logs/Actions/LogService.ClearLog
	
	sleep 10

	curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Chassis/Self/LogServices/Logs/Entries | jq

else

	echo -e "\n4-3. Chassis"$info_ty"\n\n-------------------------\n"
	echo -e "[This script will save all the output into file '4-3_Chassis_"$info_name"_"$SUT_name".txt' please check the file yourself]\n"
	curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Chassis$info_ty | jq '.' >> 4-3_Chassis_"$info_name"_"$SUT_name".txt
	echo -e "\n-------------------------\n"

fi

}

#######################################

Managers()
{

info_ty=$1

echo -e "\n4-4. Managers"$info_ty"\n\n-------------------------\n" >> 4-4_Managers_all_info_"$SUT_name".txt
echo -e "[This script will save all the output into file '4-4_Managers_all_info_"$SUT_name".txt' please check the file yourself]\n"
curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Managers$info_ty | jq '.' >> 4-4_Managers_all_info_"$SUT_name".txt
echo -e "\n-------------------------\n" >> 4-4_Managers_all_info_"$SUT_name".txt

}

#######################################

Managers_set()
{

int_ty=$1
int_ac=$2
int_pa=$3
int_name=$4

echo -e "[This script will do "$int_name" please check the reaction...]\n"
eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -X POST -d '{\"$int_ty\":\"$int_ac\"}' https://$bmcip/redfish/v1/Managers/Self$int_pa

if [ $int_name = BMC_SEL_log_clear ]; then

curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Managers/Self/LogServices/SEL/Entries | jq

fi

}

#######################################

URI()
{

info_ty=$1
nu=$2
info_name=$3

echo -e "[This script will save all the output into file '4-"$nu"_"$info_name"_all_info_"$SUT_name".txt' please check the file yourself]\n"
echo -e "\n4-"$nu". "$info_ty"\n\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt

curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/"$info_ty" | jq '.' >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt

echo -e "\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt

if [ $info_ty = TelemetryService/MetricDefinitions ] || [ $info_ty = JsonSchemas ]; then

num=$(curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/$info_ty | jq '.Members | length')

for (( i=0; i<${num}; i=i+1 ));
	do
	
	element=$(curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/$info_ty | eval jq -r '.Members[$i].\"@odata.id\"')

	echo -e "\n4-"$nu". "$element"\n\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt
	curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip$element | jq '.' >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt
	echo -e "\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt

	if [ $info_ty = JsonSchemas ]; then

	echo -e "\n4-"$nu". "$element".json\n\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt
        curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip$element.json | jq '.' >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt
        echo -e "\n-------------------------\n" >> 4-"$nu"_"$info_name"_all_info_"$SUT_name".txt

	fi

	done
fi

}

#######################################

DynamicExtension()
{

info_ty=$1
info_name=$2

if [ $info_ty = ErrorLog ] || [ $info_ty = AuditLog ]; then

echo -e "[This script will clear all "$info_ty" please check log is empty]\n"
curl -k -u $red_user:$red_pw -H "content-type:application/json" -H "accept:application/json" -d '{"ClearType":"ClearAll"}' -X POST https://$bmcip/redfish/v1/DynamicExtension/LogServices/$info_ty/Actions/LogService.ClearLog

sleep 10

curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/DynamicExtension/LogServices$info_name | jq

else

echo -e "[This script will save all the output into file '4-12_"$info_name"_all_info_"$SUT_name".txt' please check the file yourself]\n"
curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/DynamicExtension/LogServices$info_ty | jq '.' >> 4-12_"$info_name"_all_info_"$SUT_name".txt

fi

}

#######################################

Session()

{

echo -e "[This script will save all the output into file '4-6_Session_all_test_"$SUT_name".txt' please check the file yourself]\n"

echo -e "1. Create a new session.\n" >> 4-6_Session_all_test_"$SUT_name".txt

eval curl -k -u $red_user:$red_pw -H "content-type:application/json" -d '{\"UserName\":\"$red_user\"\,\"Password\":\"$red_pw\"}' -X POST https://$bmcip:/redfish/v1/SessionService/Sessions | jq '.' >> 4-6_Session_all_test_"$SUT_name".txt

echo -e "\n-------------------------\n" >> 4-6_Session_all_test_"$SUT_name".txt
echo -e "2. List session you created.\n" >> 4-6_Session_all_test_"$SUT_name".txt
curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip:/redfish/v1/SessionService/Sessions | jq '.' >> 4-6_Session_all_test_"$SUT_name".txt

echo -e "\n-------------------------\n" >> 4-6_Session_all_test_"$SUT_name".txt
echo -e "3. Delete the session\n" >> 4-6_Session_all_test_"$SUT_name".txt

element=$(curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip:/redfish/v1/SessionService/Sessions | jq -r '.Members[]."@odata.id"')

curl -k -u $red_user:$red_pw -H "content-type:application/json" -X DELETE https://$bmcip$element | jq 
curl -k -u $red_user:$red_pw -H "content-type:application/json" -X GET https://$bmcip:/redfish/v1/SessionService/Sessions | jq '.' >> 4-6_Session_all_test_"$SUT_name".txt

echo -e "\n-------------------------\n" 

}

#######################################

Event()

{

int_ty=$1

echo -e "[This script will save all the output into file '4-7_Event_test_"$SUT_name".txt' please check the file yourself]\n"

if [ $int_ty = add ]; then

echo -e "1. Add subscription.\n" >> 4-7_Event_test_"$SUT_name".txt

curl -k -u $red_user:$red_pw -H content-type:application/json -d '{"Destination":"https://10.2.0.1","EventTypes":["StatusChange"],"Context":"Gigabyte","Protocol":"Redfish"}' -X POST https://$bmcip/redfish/v1/EventService/Subscriptions | jq '.' >> 4-7_Event_test_"$SUT_name".txt

echo -e "\n-------------------------\n" >> 4-7_Event_test_"$SUT_name".txt
echo -e "2. Check subscription.\n" >> 4-7_Event_test_"$SUT_name".txt

curl -k -u $red_user:$red_pw -H content-type:application/json -X GET https://$bmcip/redfish/v1/EventService/Subscriptions | jq '.' >> 4-7_Event_test_"$SUT_name".txt

element=$(curl -k -u $red_user:$red_pw -H content-type:application/json -X GET https://$bmcip/redfish/v1/EventService/Subscriptions | jq -r '.Members[]."@odata.id"')

echo -e "\n-------------------------\n" >> 4-7_Event_test_"$SUT_name".txt
echo -e "3. Check subscription content.\n" >> 4-7_Event_test_"$SUT_name".txt

curl -k -u $red_user:$red_pw -H content-type:application/json -X GET https://$bmcip$element | jq '.' >> 4-7_Event_test_"$SUT_name".txt

else

echo -e "\n-------------------------\n" >> 4-7_Event_test_"$SUT_name".txt
echo -e "4. Delete a subscription, Check Subscription didn't list from subscription list.\n" >> 4-7_Event_test_"$SUT_name".txt

element=$(curl -k -u $red_user:$red_pw -H content-type:application/json -X GET https://$bmcip/redfish/v1/EventService/Subscriptions | jq -r '.Members[]."@odata.id"')

curl -k -u $red_user:$red_pw -H content-type:application/json -X DELETE https://$bmcip$element | jq
curl -k -u $red_user:$red_pw -H content-type:application/json -X GET https://$bmcip/redfish/v1/EventService/Subscriptions | jq '.' >> 4-7_Event_test_"$SUT_name".txt

fi

}

#######################################

Accounts()

{

int_ty=$1
int_con=$2
int_uerpass=$3
int_sta=$4

echo -e "[This script will save all the output into file '4-5_Accounts_test_"$SUT_name".txt' please check the file yourself]\n"

case ${int_ty} in

	"list")
		curl -k -u $int_uerpass -H content-type:application/json -X GET https://$bmcip/redfish/v1/AccountService$int_con | jq '.' >> 4-5_Accounts_test_"$SUT_name".txt
		;;
	"create")
		curl -k -u $red_user:$red_pw -H "contenT-type:application/json" -d '{"UserName":"user02","Password":"superuser02","RoleId":"Administrator","Enabled":true,"Locked":false,"Name":"test02","Description":"redfish_test"}' -X POST https://$bmcip/redfish/v1/AccountService/Accounts | jq '.' >> 4-5_Accounts_test_"$SUT_name".txt
		;;
	"status")
		eval curl -k -u $int_uerpass -H "content-type:application/json" -d '{\"Enabled\":$int_sta}' -X PATCH https://$bmcip/redfish/v1/AccountService$int_con | jq
		;;
	"delete")
		curl -k -u $int_uerpass -H conten-type:application/json -X DELETE https://$bmcip/redfish/v1/AccountService$int_con | jq
		;;
esac

}

#######################################

Update()

{

int_ty=$1
int_prt=$2
int_ip=$3
int_fname=$4

eval curl -v -k -u $red_user:$red_pw -H "content-type:application/json" -d '{\"ImageURI\":\"http://$int_ip:80/$int_fname\"\,\"UpdateComponent\":\"$int_ty\"\,\"TransferProtocol\":\"$int_prt\"}' -X POST https://$bmcip/redfish/v1/UpdateService/Actions/SimpleUpdate | jq

}

#######################################

Token()

{

echo -e "\n1. Create Session first and Check Token in reply header "X-Auth-Token :xxxxxxxxxxx"\n"
echo -e "\n-------------------------\n"
eval curl -v --silent -k -u $red_user:$red_pw -H "content-type:application/json" -d '{\"UserName\":\"$red_user\"\,\"Password\":\"$red_pw\"}' -X POST https://$bmcip/redfish/v1/SessionService/Sessions 2>&1 | grep X-Auth-Token | sed -n 1p | cut -f 3 -d " " > t1e1st.log

dos2unix -q t1e1st.log

token=$(cat t1e1st.log | sed -n 1p)

echo -e "\nX-Auth-Token: $token\n"
echo -e "\n-------------------------\n"
echo -e "\n2. Power off system via Token\n"
echo -e "\n-------------------------\n"
curl -k -H "X-Auth-Token: $token" -d '{"ResetType":"ForceOff"}' -X POST https://$bmcip/redfish/v1/Systems/Self/Actions/ComputerSystem.Reset | jq
echo -e "\n-------------------------\n"
rm t1e1st.log

}

#######################################

case ${test_type} in

	"red_ver")
		echo -e "\n4-1. Redfish version check\n\n-------------------------\n"
		curl -k -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/ | jq '.' > 4-1_Redfish_version_check_$SUT_name.txt
		echo -e "\n-------------------------\n"
		;;
	"sys_info")
		echo -e "\n4-2. Check system info\n\n-------------------------\n"
		curl -u $red_user:$red_pw -k -H "content-type:application/json" -X GET https://$bmcip/redfish/v1/Systems/Self | jq '.' > 4-2_Check_system_info_$SUT_name.txt
		echo -e "\n-------------------------\n"
		;;
	"p_s")
		Reset_Type GracefulShutdown
		;;
	"p_on")
		Reset_Type On
		;;	
	"p_off")
		Reset_Type ForceOff
		;;
	"p_re")
		Reset_Type ForceRestart
		;;
	"id_lit")
		IndicatorLED Lit
		;;
	"id_off")
		IndicatorLED Off
		;;
        "id_blk")
                IndicatorLED Blinking
                ;;
        "one_bs")
                BootSourceOverrideEnabled Once BiosSetup 0 0
                ;;
        "con_pxe")
                BootSourceOverrideEnabled Continuous Pxe 0 0
                ;;
        "bs_sta")
                BootSourceOverrideEnabled 1 0 0 0
                ;;
        "bs_dis")
                BootSourceOverrideEnabled Disabled None 0 0
                ;;
        "one_cd")
                BootSourceOverrideEnabled Once Cd 0 0
                ;;
        "one_usb")
                BootSourceOverrideEnabled Once Usb 0 0
                ;;
        "one_hdd")
                BootSourceOverrideEnabled Once Hdd 0 0
                ;;
        "con_uefi_pxe")
                BootSourceOverrideEnabled Continuous Pxe 1 UEFI
                ;;
        "con_lega_pxe")
                BootSourceOverrideEnabled Continuous Pxe 1 Legacy
                ;;
        "mem_info")
                System_info Memory $sys_num Memory
                ;;
        "cpu_info")
                System_info Processors $sys_num Processors
                ;;
        "lan_info")
                System_info NetworkInterfaces $sys_num NetworkInterfaces
                ;;
        "sb_info")
                System_info SecureBoot 0 SecureBoot
                ;;
        "bs_info")
                System_info BIOS 0 BIOS
		System_info BIOS/SD 0 BIOS
                ;;
	"cha_info")
		Chassis_info /Self Self
                ;;
        "cha_log")
                Chassis_info /Self/LogServices/Logs/Entries LogServices
		Chassis_info /Self/LogServices/Logs/Entries/1 LogServices 
                ;;
        "cha_log_clr")
                Chassis_info 1
                ;;
        "cha_pow")
                Chassis_info /Self/Power Power
                ;;
        "cha_temp")
                Chassis_info /Self/Thermal Thermal
                ;;
        "m_all_info")
                Managers /Self
                Managers /Self/EthernetInterfaces
		Managers /Self/EthernetInterfaces/eth1
		Managers /Self/EthernetInterfaces/usb0
		Managers /Self/EthernetInterfaces/bond0
		Managers /Self/LogServices/SEL/Entries
		Managers /Self/NetworkProtocol 
                Managers /Self/SerialInterfaces
                Managers /Self/SerialInterfaces/IPMI-SOL
                Managers /Self/SerialInterfaces/ttyS0
                Managers /Self/SerialInterfaces/ttyS1
                Managers /Self/SerialInterfaces/ttyS2
                Managers /Self/SerialInterfaces/ttyS3
                Managers /Self/SerialInterfaces/ttyS4
		Managers /Self/VirtualMedia
                Managers /Self/HostInterfaces/Self
                ;;
        "m_re")
                Managers_set ResetType ForceRestart /Actions/Manager.Reset BMC_Reset
                ;;
        "mf_re")
                Managers_set FactoryResetType ResetAll /Actions/Manager.FactoryReset BMC_Factory_Reset
                ;;
        "m_log_clr")
                Managers_set ClearType ClearAll /LogServices/SEL/Actions/LogService.ClearLog BMC_SEL_log_clear
                ;;

        "json_info")
		URI JsonSchemas 9 JsonSchemas
                ;;
        "comp_info")
                URI CompositionService 10 CompositionService
		URI CompositionService/ResourceBlocks 10 CompositionService
                URI CompositionService/ResourceZones 10 CompositionService
                URI TelemetryService 10 CompositionService
                URI TelemetryService/MetricDefinitions 10 CompositionService
                URI TelemetryService/LogServices 10 CompositionService
                URI TelemetryService/LogServices/MetricReportLog 10 CompositionService
                ;;
        "dyn_e_log")
		DynamicExtension /ErrorLog/Entries ErrorLog
                ;;
        "dyn_a_log")
                DynamicExtension /AuditLog/Entries AuditLog
                ;;
        "dyn_e_clr")
                DynamicExtension ErrorLog /ErrorLog/Entries
                ;;
        "dyn_a_clr")
                DynamicExtension AuditLog /AuditLog/Entries
                ;;
        "ca_cfg")
                echo -e "\n4-13. Configurations\n\n-------------------------\n"
                curl -k -u $red_user:$red_pw -H "content-type:application/json"  -X GET https://$bmcip/redfish/v1/configurations | jq '.' > 4-13_Get_CA_configurations_$SUT_name.txt
                echo -e "\n-------------------------\n"
                ;;
        "cd_se")
		Session
                ;;
        "add_event")
                Event add
                ;;
        "del_event")
                Event del
                ;;
        "acc_info")
		echo -e "1-1. List Account.\n" >> 4-5_Accounts_test_"$SUT_name".txt
        	Accounts list /Accounts $red_user:$red_pw
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
		echo -e "1-2. List Default Account's content.\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts list /Accounts/1 $red_user:$red_pw
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
                ;;
        "add_acc")
		echo -e "2-1. Create user02 and other properties.\n" >> 4-5_Accounts_test_"$SUT_name".txt
                Accounts create
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
		echo -e "2-2. Test user02(use user02 to login).\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts list /Accounts user02:superuser02
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts list /Accounts/2 user02:superuser02
                echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
                ;;
        "set_acc")
                echo -e "3-1. Change user enabled status to false.\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts status /Accounts/2 $red_user:$red_pw false
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
		echo -e "3-2. Access account list again(use user02 to login).\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts list /Accounts user02:superuser02
                echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
                ;;
        "del_acc")
                echo -e "4-1. Delete user02.\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts delete /Accounts/2 $red_user:$red_pw
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
		echo -e "4-2. List user again(check account delete).\n" >> 4-5_Accounts_test_"$SUT_name".txt
		Accounts list /Accounts $red_user:$red_pw
		echo -e "\n-------------------------\n" >> 4-5_Accounts_test_"$SUT_name".txt
                ;;
	"up_bios")
		Update BIOS HTTP $sys_num $sys_file
		;;
        "up_bmc")
                Update BMC HTTP $sys_num $sys_file
                ;;
        "up_cpld")
                Update BPB_CPLD FTP $sys_num $sys_file
                ;;
	"us_se")
		Token 
		;;
	*)
		echo -e "\n[Command list]\n
#./redfish {bmcip} {Command} {Command} {Command}

[Note] 
0. This scrip based on Redfish 1.2.1 Test Plan
1. Make sure ipmitool sheet already be test.
2. Install jq software for JSON format readable.
   #apt-get install jq

3. Install HTTP server
   #apt-get install apache2

4. Install dos2unix
   #apt-get install dos2unix

-------------------------

4-1 Redfish version check (log) => red_ver
4-2 Check system info (log) => sys_info

4-2 Reset Type
	GracefulShutdown => p_s
	Power On => p_on
	Force Off => p_off
	Force Restart => p_re

4-2 IndicatorLED
	ID LED keep lighting => id_lit
	ID LED turn off => id_off
	ID LED light up 15 seconds then turn off automatically => id_blk

4-2 BootSourceOverrideEnabled
	Boot Source: Once & Boot Target: BiosSetup => one_bs
	Boot Source: Continuous & Boot Target: PXE => con_pxe
	Check BootSource status => bs_sta
	Set BootSource Disable & Boot Target: none => bs_dis

4-2 BootSourceOverrideTarget
	Boot Target: Cd => one_cd
	Boot Target: Usb => one_usb
	Boot Target: Hdd => one_hdd

4-2 BootSourceOverrideMode:UEFI
	[Note] Connect to server which support UEFI PXE server
	Boot Mode: UEFI => con_uefi_pxe
	Boot Mode: Legacy => con_lega_pxe

4-2 Memory and Memory ID
	Install full DIMM on your slot ,for example your system 24 DIMMs installed on your system (log) => mem_info 24

4-2 Processor and Processor ID
	Install full CPU on your system ,for example your system 2 CPUs installed on your system (log) => cpu_info 2

4-2 BIOS and BIOS SD
        These two path can be found (log) => bs_info

4-2 NetworkInterfaces and NetworkInterfaces ID
	Check Lan port on your system ,for example your system 2 LAN ports on your system (log) => lan_info 2
	Disable LAN1 and check again ,then Disable LAN2 and check again ...etc
	When LAN1/LAN2/LANx ...etc, Disable from BIOS ,State should show '?'

4-2 SecureBoot
	SecureBoot information can be list without erros (log) => sb_info

4-3 Chassis/Self
	Chassis information can be reach withour erros (log) => cha_info

4-3 Chassis/LogServices
	List all logs first, find one of logs to check (log) => cha_log

4-3 Chassis/LogService.ClearLog
	Check all log were be clear => cha_log_clr

4-3 Chassis/Power
	List all voltage sensors which match your SDR table (log) => cha_pow

4-3 Chassis/Thermal
	List all temperature sensors which match your SDR tfable (log) => cha_temp

4-4 Managers
	BMC info: Check 'FirmwareVersion' match your BMC version (log) => m_all_info
	BMC LAN information(all): MLAN information should be list (log) => m_all_info
	BMC SEL Check (log) => m_all_info
	BMC Network Protocol: Check all service information correct (log) => m_all_info
	Serial Interfaces ,ttyS0 ~ ttyS4 ,IPMI-SOL: SerialInterfaces information can be list without error (log) => m_all_info
	Virtual Media: Virtual Media information can be list without eror (log) => m_all_info
	Host Ethernet Interfaces: Host Ethernet Interface information can be list without erros (log) => m_all_info

	BMC Reset: BMC will be reset ,same behavior ipmitool mc reset cold => m_re
	BMC Factory Reset: All items you just change will reset to factory default setting => mf_re
	BMC SEL log clear =>  m_log_clr

4-5 Accounts
	List Account: Check Default enable account (Administrator) (log) => acc_info
	Add Account: System return new ID be created and New user list accounts wihout erros (log) => add_acc
	Set Account: Confirm user02 can't access 'account list' if Enabled set to false (log) => set_acc
	Delete Account: Delete User Accounts ID 2 and list again ,account must be deleted (log) => del_acc

4-6 Session
	Create and Delete Session (log) => cd_se
	Using a Session (will Force Off your system) => us_se
	
4-7 Event
	Add subscription and check subscription (log) => add_event 
	Test event subscription => This script did not test, please check plan to test
	Delete a subscription (log) => del_even


4-9 JsonSchemas
	Check URI can be found (log) => json_info

4-10 CompositionService
	Check URI can be found (log) => comp_info

4-11 Update
	[Note] 
	1. Install HTTP server: #apt-get install apache2
	2. Copy your FW file to /var/www/html/

	Update BIOS: Reboot the system and check BIOS version match your update => up_bios your_ip xxx.RBU
	Update BMC: Reboot the system and check BMC version match your update => up_bmc your_ip xxx.bin
	Update CPLD: Reboot the system and check CPLD version match your update => up_cpld your_ip xxx.RCU

4-12 DynamicExtension
	Check Error Log (log) => dyn_e_log
	Check Audit log (log) => dyn_a_log

	Clear Error Log => dyn_e_clr
	Clear Audit log => dyn_a_clr

4-13 Configurations
	Get CA configurations (log) => ca_cfg

-------------------------
"
		;;
esac
