Note that this how-to advices you to use NetBSD 8.0, because I didn't have
any success with NetBSD 7. I use the 201709050240Z snapshot, you should use
the last one until after NetBSD 8.0 is released.

In order to boot NetBSD via PXE, you need the following:

1. Extracted NetBSD 8.0 or higher installation ISO exported via NFS.
Download it from http://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-8/201709050240Z/images/NetBSD-8.0_BETA-amd64.iso

Check the SHA512 hash:
`sha512 NetBSD-8.0_BETA-amd64.iso`

Compare it to the hash at http://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-8/201709050240Z/images/SHA512

Mount the iso with:
```
mount -o loop NetBSD-8.0_BETA-amd64.iso /mnt
```

Copy with rsync:
```
rsync -avvP /mnt/ /srv/tftp/images/netbsd/
```

`/srv/tftp` is the path to the TFTP root.

2. Relevant entry in DHCP server config:
  `option root-path "/srv/tftp/images/netbsd";`
  `/srv/tftp/images/netbsd` is the path to the extracted ISO.

3. PXE loader from http://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-8/201709050240Z/amd64/installation/misc/pxeboot_ia32.bin
Download the latest snapshot.

Check SHA512 hash with:
`sha512 pxeboot_ia32.bin`
and compare it to the hash at http://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-8/201709050240Z/amd64/installation/misc/SHA512

Put it to /srv/tftp/images/netbsd.pxeboot.
  
4. Relevant entries in PXELINUX config:
```
label NetBSD
 menu label NetBSD
 pxe images/netbsd.pxeboot
```

The path 'images/netbsd.pxeboot' is relative to TFTP root directory.

5. After choosing to load NetBSD, you need to stop the automatic booting and
type:
```
consdev com0
```

Serial connection speed will change to 9600b, so you will need to reconnect
to APU. After that, type:
```
boot netbsd
```

This will boot the NetBSD installer. Then you can proceed with installation.
Unfortunately, I was unable to successfully install NetBSD via PXE, because of
HDD-related errors. I was able to do it by installation from USB.

Unattended installation is not supported now:
http://netbsd.2816.n7.nabble.com/Anyone-working-on-an-automated-install-td107128.html
https://mail-index.netbsd.org/tech-install/2012/06/18/msg000319.html
