# 2019/01/14 Version 0.1 written by Kid.fang
# 2019/01/15 Version 0.2 change the input item to the top written by Kid.fang
# ipmi_RESTful.sh 192.168.10.1

bmc_ip=$1
bmc_user=admin
bmc_password=password

echo -e "\nPlease input update method(https/tftp): "

read update_method

echo -e "\nPlease input flash type (BMC/BIOS/BPB_CPLD): "

read flash_mode

if [ $flash_mode = BMC ];
then
        echo -e "\nPlease input image configuration: \n\n 0 => inactive image \n 1 => image 1 \n 2 => image 2 \n 3 => both \n\n Input 0 or 1 or 2 or 3 :"
        read image_update
fi

if [ $update_method = tftp ];
then
        echo -e "\nPlease input TFTP server IP address: "

        read server_add

        echo -e "\nPlease input FW image name: "
        read fwname
else
	echo -e "\nPlease input FW image name: "
        read fw_name
fi

echo -e "\nPlease input flash status: \n\n 0=For BPB_CPLD only \n 1=Full Firmware Flash \n 2=Section Based Flash \n\n Input 0 or 1 or 2 :"
read flash_sta

echo -e "\nPlease input preserve config: \n\n 0=disable \n 1=enable \n\n Input 0 or 1 :"
read pre_con

echo -e "\n========================================\n\n 1-1. Create session =>\n"

token=$(curl -s -c /tmp/cookie.txt -d "username=$bmc_user&password=$bmc_password" -H "application/x-www-form-urlencoded" -X POST https://${bmc_ip}/api/session -k | cut -f 10 -d ":" | cut -c 3-10)
echo -e "CSRFToken : $token"

if [ $update_method = tftp ];
then
	echo -e "\n========================================\n\n 1-1-a. Set TFTP setting =>\n"

	eval curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -d '{\"id\":1\,\"protocol_type\":\"tftp\"\,\"server_address\":\"$server_add\"\,\"image_name\":\"$fwname\"\,\"retry_count\":2}' -H "Accept:application/json" -H "Content-Type:application/json" -X PUT https://${bmc_ip}/api/maintenance/fwimage_location -k

else
	echo -e "\n========================================\n\n 1-1-a. Set TFTP setting => \n\nNot TFTP, skip this item ..."
fi


if [ $flash_mode = BMC ];
then
	echo -e "\n\n========================================\n\n 1-2. Set dual flash image configuration (Update BMC only) => \n"
	
	eval curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -d '{\"image_update\":\"$image_update\"}' -H "Accept:application/json" -H "Content-Type:application/json" -X PUT https://${bmc_ip}/api/maintenance/dualflashimageconfig -k	

else
	echo -e "\n\n========================================\n\n 1-2. Set dual flash image configuration (Update BMC only) => \n\nNot BMC, skip this item ..."
fi

echo -e "\n\n========================================\n\n 1-3. Set flash mode => \n"
	
eval curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -d '{\"flash_type\":\"$flash_mode\"}' -H "Accept:application/json" -H "Content-Type:application/json" -X PUT https://${bmc_ip}/api/maintenance/flash -k 

if [ $update_method = https ];
then

	echo -e "\n\n========================================\n\n 1-4. Upload firmware image => \n"

	echo -e "\n"

	curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -F fwimage=@"/root/$fw_name" -H "Accept: application/json" -H "Content-Type: multipart/form-data" -X POST https://${bmc_ip}/api/maintenance/firmware -k

else
	echo -e "\n\n========================================\n\n 1-4. Oder BMC to download image => \n"
	curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -d '{"PROTOTYPE" : 1}'  -H "Accept:application/json" -H "Content-Type:application/json" -X PUT https://${bmc_ip}/api/maintenance/firmware/dwldfwimg -k

	echo -e "\n\n========================================\n\n 1-4-a. Monitor download progress =>"
	Isout="No"

	until [ "$Isout" = "Complete" ]
	do
		Isout=$(curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -H "application/json" -X GET https://${bmc_ip}/api/maintenance/firmware/dwldfwstatus-progress -k | cut -f 3 -d "," | cut -c 15-22)
		echo -e "\n\nDownloading.. $Isout"
		sleep 10
	done
fi
	
echo -e "\n\n========================================\n\n 1-5. Firmware verification => \n"

curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -H "application/x-www-form-urlencoded" -X GET https://${bmc_ip}/api/maintenance/firmware/verification?flash_type=${flash_mode} -k

echo -e "\n\n========================================\n\n 1-6. Start to update => \n"

eval curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -d '{\"flash_status\":$flash_sta\,\"preserve_config\":$pre_con\,\"flash_type\":\"$flash_mode\"}' -H "Accept:application/json" -H "Content-Type:application/json" -X PUT https://${bmc_ip}/api/maintenance/firmware/upgrade -k

echo -e "\n\n========================================\n\n 1-7. Monitor flash progress => \n"

Is_out="No"
echo -e "Note: If you set image_update to 3 in 1-2, the progress will from 0%->100%->0%->100%->Complete"

until [ "$Is_out" = "Comp" ]
do
	Is_out=$(curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -H "application/json" -X GET https://${bmc_ip}/api/maintenance/firmware/flash-progress -k | cut -f 3 -d "," | cut -c 15-18)
	Is_out_a=$(curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -H "application/json" -X GET https://${bmc_ip}/api/maintenance/firmware/flash-progress -k | cut -f 3 -d "," | cut -c 15-23)

	if [ "$Is_out" = "Comp" ]
	then
		Is_out_a=Complete
	fi

	echo -e "\n\nFirmware Update: $Is_out_a"
	sleep 10
done

echo -e "\n\n========================================\n\n 1-8. Reset BMC => \n"

curl -s -b /tmp/cookie.txt -H "X-CSRFTOKEN:$token" -H "Content-Length:0" -X POST https://${bmc_ip}/api/maintenance/reset -k

echo -e "\n Flash Complered, it will Reset system BMC,  please check your system. thx! \n\n========================================"
