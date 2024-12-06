passwd root
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart sshd
systemctl restart ssh.service
# Auto login
# sed -i 's/ExecStart=-/sbin/agetty -o '-p -- \u' --noclear %I $TERM/ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM/g' /lib/systemd/system/getty@.service
