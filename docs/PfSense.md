In order to boot PfSense via PXE and use unattended install,
you need the following:

1. Extracted PfSense installation ISO exported via NFS.

2. Relevant entry in DHCP server config:
    `option root-path "/srv/tftp/images/pfsense";`
   /srv/tftp/images/pfsense is the path to the extracted ISO.

3. Relevant entries in PXELINUX config:
```
label PfSense
 menu label PfSense
 pxe images/pfsense/boot/pxeboot
```

The path `images/pfsense/boot/pxeboot` is relative to TFTP root directory.
It's a path to the PXE loader in the extracted PfSense installation image.

Unfortunately, there's no mechanism for unattended installation of PfSense.
