#!/bin/bash
#Setup nfs server on Centos7

# sudo yum install nfs-utils
# sudo echo '$NFSROOT     192.168.0.1/24(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports
# sudo exports -ra

# sudo firewall-cmd --permanent --add-port=69/udp
# sudo firewall-cmd --zone=public --add-service=tftp --permanent
# sudo firewall-cmd --permanent --add-port=2049/tcp
# sudo firewall-cmd --zone=public --add-service=nfs --permanent
# sudo systemctl restart firewalld

#Setup nfs server on Debian-like system

sudo mkdir $NFSROOT
sudo echo "$NFSROOT    192.168.0.1/24(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
sudo chown root:root $NFSROOT
sudo chmod 755 $NFSROOT

apt-get install nfs-kernel-server nfs-common
/etc/init.d/nfs-kernel-server restart

sudo debootstrap --foreign --arch amd64 jessie $NFSROOT http://deb.debian.org/debian
sudo cp /etc/resolv.conf $NFSROOT/etc/resolv.conf
sudo chroot $NFSROOT
# Inside nfsroot as chroot

/debootstrap/debootstrap   --second-stage --verbose
echo "pcengines" > /etc/hostname
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
EOF

echo "deb http://deb.debian.org/debian jessie main" > /etc/apt/sources.list

apt-get install -y --force-yes nfs-common locales sudo bc ssh ntpdate gettext \
  autoconf wpasupplicant dialog makedev binutils


echo "Now provide user password and other data"

adduser $USERNAME
usermod -a -G sudo $USERNAME
exit
