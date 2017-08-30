#!/bin/bash
# Usage:
# NFS_SRV_IP=<server-ip> ./init.sh

ipvalid() {
  # Set up local variables
  local ip=$NFS_SRV_IP
  local IFS=.; local -a a=($ip)
  # Start with a regex format test
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
  # Test values of quads
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 1
  done
  return 0
}

if [ -z "$NFS_SRV_IP" ]; then
	echo "Please provide NFS server ip as NFS_SRV_IP"
	exit 1
fi

if ipvalid "$NFS_SRV_IP"; then
  echo "NFS server ip ($NFS_SRV_IP) is valid"
else
  echo "Wrong server ip address ($NFS_SRV_IP)"
  exit 1
fi

git clone git@github.com:3mdeb/netboot.git

cd netboot

sed -i "s/192.168.0.109/$NFS_SRV_IP/"  ./debian-installer/i386/boot-screens/menu.cfg
 
wget http://ftp.debian.org/debian/dists/wheezy/main/installer-i386/current/images/netboot/netboot.tar.gz

tar -xzvf netboot.tar.gz -C . --skip-old-files && rm  netboot.tar.gz

wget https://cloud.3mdeb.com/index.php/s/rAeHunCKaC1F7H9/download -O kernels.tar.gz

tar -xzvf kernels.tar.gz && rm kernels.tar.gz

cd ..
wget https://cloud.3mdeb.com/index.php/s/Dufv3NBqYWS38Ea/download -O Debian.tar.gz

mkdir debian
tar -xvpzf Debian.tar.gz -C ./debian --numeric-owner 

mkdir voyage
wget https://cloud.3mdeb.com/index.php/s/tU2mEoY7UEbIWT1/download -O voyage-0.11.0_amd64.tar.gz

tar -xzvf voyage-0.11.0_amd64.tar.gz -C ./voyage
rm voyage-0.11.0_amd64.tar.gz Debian.tar.gz
