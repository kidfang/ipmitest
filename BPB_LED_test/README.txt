[AMD patch] 
Booting to Linux based OS, SGPIO signals are disappeared. Below is patch for Linux based.
1.	Execute below commands to config AHCI driver to patch issue of SGPIO signal disappeared 
2.	#sudo vi /etc/default/grub
3.	Add “libahci.ahci_em_messages=0” in GRUB_CMDLINE_LINUX as below.

5.	Rebuild the config file as below command
6.	#sudo update-grub
7.	#sudo reboot

[Test steps]
1.	Install utility
    # sudo apt install devmem2
2.	Copy amd_sgpio_test_20180509.sh into system.
3.	Run test script


