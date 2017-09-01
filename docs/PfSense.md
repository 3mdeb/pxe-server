In order to boot PfSense via iPXE,
you need to do the following:

1. Download ISO from https://nyifiles.pfsense.org/mirror/downloads/pfSense-CE-2.3.4-RELEASE-amd64.iso.gz
   
   You should also check the SHA256 hash:
   `sha256 -c 610b2a8c696e1d1854845d553ce8540debaab9d78ed6c15ce83872eaeac9d05f pfSense-CE-2.3.4-RELEASE-amd64.iso.gz`
   
2. Extract the ISO contents to a directory called
    `images/pfsense` in TFTP root:
    `gzip -d pfSense-CE-2.3.4-RELEASE-amd64.iso.gz`
    
   In order to extract the contents, you need to mount
   the ISO with following commands (example from FreeBSD):
   `mount_cd9660 /dev/$(mdconfig -a -t vnode -f pfSense-CE-2.3.4-RELEASE-amd64.iso) /mnt`
   
   To mount the ISO from GNU / Linux use:
   `mount -o loop pfSense-CE-2.3.4-RELEASE-amd64.iso /mnt`
   
   Then:
   `rsync -avvP /mnt/ /srv/tftp/images/pfsense/`
   You need to have `rsync` installed.

2. Relevant entry in DHCP server config:
    `option root-path /srv/tftp/images/pfsense;`
   `/srv/tftp/images/pfsense` is the path to the extracted ISO.

3. Relevant entries in PXELINUX config:
```
label PfSense
 menu label PfSense
 pxe images/pfsense/boot/pxeboot
```

The path `images/pfsense/boot/pxeboot` is relative to TFTP root directory.
It's a path to the PXE loader in the extracted PfSense installation image.

Unfortunately, there's no mechanism for unattended installation of PfSense.
PfSense documentation doesn't mention this:
https://doc.pfsense.org/index.php/Installing_pfSense
