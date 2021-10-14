# ipmitest
git clone https://github.com/kidfang/ipmitest.git

# Root login under ubuntu
passwd root

sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

systemctl restart sshd 

# Samba_server_under_centos
if connect to smba folder failed please restart samba service and retry

systemctl restart smb.service

systemctl restart nmb.service

# Update Ubuntu 18.04.3 kernel
sudo apt-get install --install-recommends linux-generic-hwe-18.04

# Update CentOS kernel
http://elrepo.org/tiki/tiki-index.php

http://blog.itist.tw/2016/03/how-to-upgrade-newest-kernel-on-centos-7.html

yum install https://www.elrepo.org/elrepo-release-8.0-2.el8.elrepo.noarch.rpm

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

yum -y --enablerepo=elrepo-kernel install kernel-ml

# Change default kernel on Boot - CentOS

https://www.digitalocean.com/community/questions/change-default-kernel-on-boot-centos

ex: grub2-set-default 2

# Subscript RHEL

subscription-manager register --username xxxxx --password xxxxx

subscription-manager attach --auto

[HTTP error issue solved]

Adding the system as a new system to https://access.redhat.com/management/systems/create and registering the system with the generated UUID on the portal:

subscription-manager register --consumerid=UUID

The UUID can be found by clicking on the host name in UUID from https://access.redhat.com/management/systems

[SSL error]

Unable to verify server's identity: [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:897)

follow the steps below:

vi /etc/rhsm/rhsm.conf

Set to 1 to disable certificate validation:
insecure = 1

https://access.redhat.com/discussions/4487561

[RHEL7]
subscription-manager repos --enable rhel-7-server-optional-rpms

[RHEL8]
subscription-manager repos --enable rhel-8-for-x86_64-baseos-source-rpms

# Linux OS crash to fix

xfs_repair -v -L /dev/dm-0

# NFS server (Ubuntu20.04.1)

apt-get install nfs-kernel-server nfs-common

mkdir -p /var/nfsshare
chmod -R 777 /var/nfsshare/

vi  /etc/exports

=> /var/nfsshare    *(rw,sync,no_root_squash,no_all_squash,insecure)

/etc/init.d/nfs-kernel-server restart
showmount -e
=> Export list for test:
=> /var/nfsshare *

cat /proc/filesystems
=> check support nfsd

----------

# Client into NFS

[Windows 10]
1. Enable NFS service
Control Panel\Programs\Programs and Features
Turn Windows feature on or off
Check "Services for NFS" enable

2.    \\192.168.50.190\var\nfsshare

[Linux OS ubuntu]
apt-get install nfs-common

mount -t nfs 192.168.50.190:/var/nfsshare /mnt -o nolock

cd /mnt

=> will find the file under NFS Server

---------------

# FTP Server 

[Download]

a. Windows 
ftp://192.168.50.1

b. Linux
yum install ftp

ftp 192.168.50.1

ls

cd

lcd /root    //set download file locate

get $filename

[Update]
put /path/file
