#!/bin/bash

# Disable the root account
usermod root -p '!!'

# Remove unneeded parameters in grub
sed -i 's/ numa=off//g' /boot/grub/grub.conf
sed -i 's/ rhgb//g' /boot/grub/grub.conf
sed -i 's/ quiet//g' /boot/grub/grub.conf
sed -i 's/ crashkernel=auto//g' /boot/grub/grub.conf

# Set OL repos
curl -so /etc/yum.repos.d/CentOS-Base.repo https://raw.githubusercontent.com/szarkos/AzureBuildCentOS/master/config/azure/CentOS-Base.repo
curl -so /etc/yum.repos.d/OpenLogic.repo https://raw.githubusercontent.com/szarkos/AzureBuildCentOS/master/config/azure/OpenLogic.repo

# Import CentOS and OpenLogic public keys
curl -so /etc/pki/rpm-gpg/OpenLogic-GPG-KEY https://raw.githubusercontent.com/szarkos/AzureBuildCentOS/master/config/OpenLogic-GPG-KEY
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
rpm --import /etc/pki/rpm-gpg/OpenLogic-GPG-KEY

# Modify yum
echo "http_caching=packages" >> /etc/yum.conf

# Enable SSH keepalive
sed -i 's/^#\(ClientAliveInterval\).*$/\1 180/g' /etc/ssh/sshd_config

# Changing password retrictions defined by CIS CentOS Linux 6 Benchmark
sudo sed -i 's/pam_cracklib.so try_first_pass retry=3 type=/\pam_cracklib.so try_first_pass retry=3 minlen=14 dcredit=-1 ucredit=-1 ocredit=-1 lcredit=-1/g' /etc/pam.d/system-auth

# Configure network
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
TYPE=Ethernet
USERCTL=no
PEERDNS=yes
IPV6INIT=no
EOF

cat << EOF > /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=localhost.localdomain
EOF

# Disable persistent net rules
touch /etc/udev/rules.d/75-persistent-net-generator.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules /etc/udev/rules.d/70-persistent-net.rules

# Disable some unneeded services by default (administrators can re-enable if desired)
chkconfig cups off

# TEMPORARY - Install the Azure Linux agent
#curl -so /root/WALinuxAgent-2.1.3-1.noarch.rpm https://raw.githubusercontent.com/szarkos/AzureBuildCentOS/master/rpm/6/WALinuxAgent-2.1.3-1.noarch.rpm
#rpm -i /root/WALinuxAgent-2.1.3-1.noarch.rpm
#rm -f /root/WALinuxAgent-2.1.3-1.noarch.rpm
#chkconfig waagent on

# Deprovision and prepare for Azure
/usr/sbin/waagent -force -deprovision
