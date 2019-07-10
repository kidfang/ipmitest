#!/bin/bash
SATAAHCIHOST="0xeff02000 0xeda02000" #"Die0 Die1"
# MZ81-EX0 ee602000 (04:00.2)
# MZ81-EX0 e2f02000 (42:00.2) without NVMe
# MZ81-EX0 e2b02000 (44:00.2) with 4 NVMe

show_menu(){
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    GREEN=`echo "\033[32m"` #
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}****************** ${RED_TEXT}[MZ81-EX0 20180509]${MENU} *****************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Turn on all ${GREEN}Locate LED.${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Turn on all ${NUMBER}Fault LED. ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Turn off all LED. ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Install devmem2 utility.${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Turn on all ${GREEN}Activity LED.${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Turn on all ${NUMBER}ReBuild LED.${NORMAL}"
    #echo -e "${MENU}**${NUMBER} 5)${MENU} ${NORMAL}"
    echo -e "${MENU}*********************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read opt
}
option_picked(){
    COLOR='\033[01;31m' # bold red
    RESET='\033[00;00m' # normal white
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
}

set_led()
{
array=$(lspci | grep SATA | awk '{ print $1 }')
sata_sgpio_reg_array=("504" "508" "50C" "020")

for slot in $array
        do
        mem=$(lspci -s $slot -v | grep Memory | awk '{ print $3 }' | sed 's/.\{3\}$//')
        #echo 0x"$mem" | sed -r 's/000/504/g'
        #echo "${mem: : -3}"
        #echo 0x$mem${sata_sgpio_reg_array[0]}
        # die 0 port 0~3
		devmem2 0x$mem${sata_sgpio_reg_array[0]} w 0x00C00000
		devmem2 0x$mem${sata_sgpio_reg_array[1]} w 0x00000001
		devmem2 0x$mem${sata_sgpio_reg_array[2]} w 0x00000060
		devmem2 0x$mem${sata_sgpio_reg_array[3]} w 0x00000100
		devmem2 0x$mem${sata_sgpio_reg_array[0]} w 0x00030000
		devmem2 0x$mem${sata_sgpio_reg_array[1]} w 0x00000001
		devmem2 0x$mem${sata_sgpio_reg_array[2]} w $1
		devmem2 0x$mem${sata_sgpio_reg_array[3]} w 0x00000100

		# die 0 port 4~7
		devmem2 0x$mem${sata_sgpio_reg_array[0]} w 0x00C00000
		devmem2 0x$mem${sata_sgpio_reg_array[1]} w 0x00000001
		devmem2 0x$mem${sata_sgpio_reg_array[2]} w 0x00000061
		devmem2 0x$mem${sata_sgpio_reg_array[3]} w 0x00000100
		devmem2 0x$mem${sata_sgpio_reg_array[0]} w 0x00030000
		devmem2 0x$mem${sata_sgpio_reg_array[1]} w 0x00000001
		devmem2 0x$mem${sata_sgpio_reg_array[2]} w $1
		devmem2 0x$mem${sata_sgpio_reg_array[3]} w 0x00000100
        done
}  >/dev/null 2>&1

clear
show_menu
while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then 
            exit;
    else
        case $opt in
        1) clear;
	option_picked "Option 1 Picked";
	set_led 0x08080808;
	show_menu;
	;;

        2) clear;
        option_picked "Option 2 Picked";
	set_led 0x01010101;
        show_menu;
            ;;

        3) clear;
        option_picked "Option 3 Picked";
	set_led 0x00000000;
        show_menu;
            ;;
	
        4) clear;
            option_picked "Option 4 Picked";
        apt-get -y install devmem2; 
            show_menu;
            ;;

        5) clear;
        option_picked "Option 5 Picked";
	set_led 0x20202020;
        show_menu;
            ;;

        6) clear;
        option_picked "Option 6 Picked";
	set_led 0x09090909;
        show_menu;
            ;;

        x)exit;
        ;;

        \n)exit;
        ;;

        *)clear;
        option_picked "Pick an option from the menu";
        show_menu;
        ;;
    esac
fi
done
