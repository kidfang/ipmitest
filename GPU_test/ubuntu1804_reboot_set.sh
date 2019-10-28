#link rc-local.service
ln -fs /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service

#edit rc-local.service
echo "
[Install]
WantedBy=multi-user.target
Alias=rc-local.service
" >> /etc/systemd/system/rc-local.service

#create rc.local
touch /etc/rc.local

#add permission
chmod +x /etc/rc.local

#set reboot script into rc.local
echo "#!/bin/bash
/home/smbuser/reboot.sh
" > /etc/rc.local
