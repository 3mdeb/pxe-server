# Usage:
# USER=<cloud-username> ./init.sh

git clone git@github.com:miczyg1/netboot.git

cd netboot

echo "Enter 3mdeb cloud user password"
 
wget http://ftp.debian.org/debian/dists/wheezy/main/installer-i386/current/images/netboot/netboot.tar.gz

tar -kxzvf netboot.tar.gz -C . --skip-old-files && rm  netboot.tar.gz

wget --user=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/kernels.tar.gz

tar -xzvf kernels.tar.gz && rm kernels.tar.gz

cd ..
echo "Enter 3mdeb cloud user password"
wget --user=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/Debian.tar.gz

mkdir debian
tar -xvpzf Debian.tar.gz -C ./debian --numeric-owner && rm Debian.tar.gz

mkdir voyage
echo "Enter 3mdeb cloud user password"
wget --sure=$CLOUD_USER --ask-password https://cloud.3mdeb.com/remote.php/webdav/projects/pcengines/OSimages/voyage-0.11.0_amd64.tar.gz

tar -xzvf voyage-0.11.0_amd64.tar.gz -C ./voyage && rm voyage-0.11.0_amd64.tar.gz


