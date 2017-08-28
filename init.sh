# Usage:
# CLOUD_USER=<cloud-username> NFS_SRV_IP=<server-ip> ./init.sh

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

if [ -n "$NFS_SRV_IP" ]; then
	echo "Please provide NFS server ip as NFS_SRV_IP"
	exit 1
fi

if if [ -n "$CLOUD_USER" ]; then
	echo "Please provide 3mdeb cloud username as CLOUD_USER"
	exit 1
fi


if ipvalid "$NFS_SRV_IP"; then
  echo "NFS server ip ($NFS_SRV_IP) is valid"
  exit 0
else
  echo "Wrong server ip address ($NFS_SRV_IP)"
  exit 1
fi



git clone git@github.com:miczyg1/netboot.git

cd netboot

sed -i "s/192.168.0.109/$NFS_SRV_IP/"  ./debian-installer/i386/boot-screens/menu.cfg
 
wget http://ftp.debian.org/debian/dists/wheezy/main/installer-i386/current/images/netboot/netboot.tar.gz

tar -kxzvf netboot.tar.gz -C . --skip-old-files && rm  netboot.tar.gz

echo "Enter 3mdeb cloud user password"
wget --user=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/kernels.tar.gz

tar -xzvf kernels.tar.gz && rm kernels.tar.gz

cd ..
echo "Enter 3mdeb cloud user password"
wget --user=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/Debian.tar.gz

mkdir debian
tar -xvpzf Debian.tar.gz -C ./debian --numeric-owner 

mkdir voyage
echo "Enter 3mdeb cloud user password"
wget --user=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/voyage-0.11.0_amd64.tar.gz

tar -xzvf voyage-0.11.0_amd64.tar.gz -C ./voyage && rm voyage-0.11.0_amd64.tar.gz Debian.tar.gz

echo "Enter root password to load nfs kernel modules"
sudo su

modprobe nfs
modprobe nfsd
modprobe nfsv3

exit
