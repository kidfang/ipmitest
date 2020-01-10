adduser smbuser --shell /bin/false
smbpasswd -a smbuser

echo "
# See smb.conf.example for a more detailed config file or
# read the smb.conf manpage.
# Run 'testparm' to verify the config is correct after
# you modified it.

#[global]
#       workgroup = SAMBA
#       security = user

#       passdb backend = tdbsam

#       printing = cups
#       printcap name = cups
#       load printers = yes
#       cups options = raw

#[homes]
#       comment = Home Directories
#       valid users = %S, %D%w%S
#       browseable = No
#       read only = No
#       inherit acls = Yes

[printers]
        comment = All Printers
        path = /var/tmp
        printable = Yes
        create mask = 0600
        browseable = No

[print$]
        comment = Printer Drivers
        path = /var/lib/samba/drivers
        write list = root
        create mask = 0664
        directory mask = 0775

[public]
        path = /home/smbuser
        available = yes
        valid users = smbuser
        read only = no
        browseable = yes
        public = yes
        writable = yes
" > /etc/samba/smb.conf

chown -R smbuser /home/smbuser/
chmod -R 0770 /home/smbuser/
chcon -t samba_share_t /home/smbuser/

systemctl enable smb.service
systemctl enable nmb.service

systemctl restart smb.service
systemctl restart nmb.service

systemctl stop firewalld.service
systemctl disable firewalld.service
