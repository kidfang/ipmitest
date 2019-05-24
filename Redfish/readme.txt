[Command list]

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
        Using a Session => us_se

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
