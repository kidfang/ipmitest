
apt-get install samba -y

adduser smbuser --shell /bin/false

smbpasswd -a smbuser

echo "[public]
path = /home/smbuser
available = yes
valid users = smbuser 
read only = no
browseable = yes
public = yes
writable = yes" >>  /etc/samba/smb.conf

service smbd restart
