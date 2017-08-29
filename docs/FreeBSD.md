In order to boot FreeBSD via PXE and use unattended install,
you need the following:

1. Extracted FreeBSD installation ISO exported via NFS.

2. Relevant entry in DHCP server config:
  `option root-path "/srv/tftp/images/freebsd";`
  `/srv/tftp/images/freebsd` is the path to the extracted ISO.
  
3. Relevant entries in PXELINUX config:
```
label FreeBSD
 menu label FreeBSD
 pxe images/freebsd/boot/pxeboot
```

The path 'images/freebsd/boot/pxeboot' is relative to TFTP root directory.
It's a path to the PXE loader in the extracted FreeBSD installation image.

4. You only need this if you want to use unattended install mechanism.

FreeBSD uses configuration file which needs to be located in
`/etc/installerconfig` of the exported NFS filesystem.

The configuration file has two sections:
a) preambule - options with which the installations will be performed,
b) setup script - a script that runs after the OS is installed, You can perform
anything you need to run to customize the OS.

Example of a script:
```
export ZFSBOOT_DISKS="da0"
export nonInteractive="YES"
DISTRIBUTIONS="kernel.txz kernel-dbg.txz base.txz base-dbg.txz doc.txz lib32.txz lib32-dbg.txz src.txz"

#!/bin/sh
cat << BOOT > /boot/loader.conf
boot_multicons="YES"
boot_serial="YES"
comconsole_speed="115200"
console="comconsole,vidconsole"
kern.cam.boot_delay="10000"
zfs_load="YES"
amdtemp_load="YES"
BOOT

cat > /etc/rc.conf << RC_CONF
hostname="3mdeb.dev"
sshd_enable="YES"
ntpd_enable="YES"
ntpd_sync_on_start="YES"
keymap=pl
ifconfig_igb0="SYNCDHCP"
zfs_enable="YES"
RC_CONF

/bin/cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
/usr/bin/touch /etc/wall_cmos_clock
/sbin/adjkerntz -a

/sbin/dhclient igb0
env PAGER=cat freebsd-update fetch install

mkdir /home/emdeb
cp /usr/share/skel/dot.cshrc /home/emdeb/.cshrc
cp /usr/share/skel/dot.login /home/emdeb/.login
cp /usr/share/skel/dot.login_conf /home/emdeb/.login_conf
cp /usr/share/skel/dot.mail_aliases /home/emdeb/.mail_aliases
cp /usr/share/skel/dot.mailrc /home/emdeb/.mailrc
cp /usr/share/skel/dot.profile /home/emdeb/.profile
cp /usr/share/skel/dot.rhosts /home/emdeb/.rhosts
cp /usr/share/skel/dot.shrc /home/emdeb/.shrc
chown -R 1000:1000 /home/emdeb

reboot
```

This script installs FreeBSD on ZFS on da0 drive. It installs the whole base
system with i386 compatibility libs and debug symbols in case you need to debug.

After the installation, `/boot/loader.conf` is set up to allow serial console,
load amdtemp(4) module to detect CPU temperature and ZFS module.
In `/etc/rc.conf`, I set up hostname, enable SSH and NTPD daemons,
set keymap to Polish, enable DHCP on igb0 NIC and enable ZFS.

Next, I set up time zone, install updates and create user directory with necessary files.

FreeBSD uses `/etc/passwd` and `/etc/master.passwd` files
for easy text access to the user accounts data.
It also has db(3)-format databases with user accounts.

Those files have been precreated by me and `base.txz` set has been apriopriately modified.
Login data are:
Login: emdeb
Password: 3mdeb.dev
