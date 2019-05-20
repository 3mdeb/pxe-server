In order to perform unattended installation of Debian via PXE,
you need the following:
1. Download http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
and check its SHA256 hash:
`sha256 netboot.tar.gz`

Compare it to the one at http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/SHA256SUMS

Extract it to the TFTP root:
`tar xvvfz netboot.tar.gz`

2. Add the following entry to `pxelinux.cfg/default`:
```
label Debian
 menu label Debian
 path debian-installer/amd64/boot-screens/
 kernel debian-installer/amd64/linux
 append auto=true priority=critical vga=788 initrd=debian-installer/amd64/initrd.gz url=http://192.168.0.1/preseed/preseed.cfg netcfg/choose_interface=auto --- console=ttyS0,115200 earlyprint=serial,ttyS0,115200
 default debian-installer/amd64/boot-screens/vesamenu.c32
 prompt 0
 timeout 0
```

3. Change the IP in URL if necessary. You need HTTP server,
the install config will need to be downloaded from there.

4. An example of preseed.cfg:
```
d-i debian-installer/locale string en_US
d-i localechooser/supported-locales multiselect pl_PL.UTF-8, pl_PL
d-i keyboard-configuration/xkb-keymap select pl
d-i netcfg/choose_interface select auto
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/wireless_wep string
d-i mirror/country string manual
d-i mirror/http/hostname string ftp.pl.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i mirror/suite string stable
d-i passwd/root-password password 3mdeb.dev
d-i passwd/root-password-again password 3mdeb.dev
d-i passwd/user-fullname string 3mdeb
d-i passwd/username string emdeb
d-i passwd/user-password password 3mdeb.dev
d-i passwd/user-password-again password 3mdeb.dev
d-i clock-setup/utc boolean true
d-i time/zone string Europe/Warsaw
d-i clock-setup/ntp boolean true
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i partman-md/confirm boolean true
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i base-installer/kernel/image string linux-image-amd64
tasksel tasksel/first multiselect standard, ssh-server
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev  string /dev/sda
d-i finish-install/reboot_in_progress note
```

This config automatically sets up HDD to use the whole disk and create one
large partition. It creates a user account (login emdeb, password 3mdeb.dev),
sets root password to 3mdeb.dev. It also installs SSH server and GRUB (in MBR).
