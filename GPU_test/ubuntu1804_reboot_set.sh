ln -fs /lib/systemd/system/rc-local.service /etc/systemd/system/rc-local.service

echo "
[Install]
WantedBy=multi-user.target
Alias=rc-local.service
" >> /etc/systemd/system/rc-local.service

touch /etc/rc.local

chmod -R 777 /etc/rc.local

echo "
#!/bin/bash
/home/smbuser/reboot.sh
" > /etc/rc.local
