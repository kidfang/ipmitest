[AMD patch] 
Booting to Linux based OS, SGPIO signals are disappeared. Below is patch for Linux based.
1.	Execute below commands to config AHCI driver to patch issue of SGPIO signal disappeared 
2.	#sudo vi /etc/default/grub
3.	Add “libahci.ahci_em_messages=0” in GRUB_CMDLINE_LINUX as below.

GRUB_DEFAULT=0
GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=2
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT=""
GRUB_CMDLINE_LINUX="libahci.ahci_em_messages=0"

5.	Rebuild the config file as below command
6.	#sudo update-grub

root@ubuntu:~/ipmitest/BPB_LED_test# update-grub
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-4.15.0-29-generic
Found initrd image: /boot/initrd.img-4.15.0-29-generic
Adding boot menu entry for EFI firmware configuration
done

7.	#sudo reboot

[Test steps]
1.	Install utility
    # sudo apt install devmem2
2.	Copy amd_sgpio_test_20180509.sh into system.
3.	Run test script
