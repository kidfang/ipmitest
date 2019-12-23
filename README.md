# ipmitest
git clone https://github.com/kidfang/ipmitest.git

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
