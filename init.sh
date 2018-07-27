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

git clone https://github.com/3mdeb/netboot.git

sed -i "s/replace_with_ip/$NFS_SRV_IP/g"  ./netboot/menu.ipxe

wget https://cloud.3mdeb.com/index.php/s/UQQVYrNIhg7ddwj/download -O kernels.tar.gz

tar -xzvf kernels.tar.gz -C ./netboot && rm kernels.tar.gz

wget https://cloud.3mdeb.com/index.php/s/9b8h6WmJcNsuB57/download -O debian-stable.tar.gz
wget https://cloud.3mdeb.com/index.php/s/fzQ2FaRTdMvzXqO/download -O xen.tar.gz
wget https://cloud.3mdeb.com/index.php/s/AQuUdsYkBzO9UJz/download -O core.tar.gz

mkdir debian
tar -xvpzf debian-stable.tar.gz -C ./debian --numeric-owner
tar -xvpzf xen.tar.gz -C ./debian --numeric-owner

mkdir voyage
wget https://cloud.3mdeb.com/index.php/s/rUZPwRHOjxpSxN4/download -O voyage-0.11.0_amd64.tar.gz

tar -xvpzf core.tar.gz -C ./netboot

tar -xzvf voyage-0.11.0_amd64.tar.gz -C ./voyage
rm voyage-0.11.0_amd64.tar.gz 
rm debian-stable.tar.gz
rm xen.tar.gz
rm core.tar.gz
