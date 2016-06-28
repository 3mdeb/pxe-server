This repository contains PXE server that should help in installing, testing and
developing operating system and firmware for PXE-capable platforms.

It was inspired by effort required to test PC Engines APU2 platform.

Server runs builds and runs as Docker container which exposes port 69. There is
silent assumption that your host doesn't have port 69 used.

Usage
-----

```
git clone https://github.com/3mdeb/pxe-server.git
./init.sh
```

_NOTE_: by default `init.sh` will use `../netboot` and `../nfs` for pxelinux
configuration and nfs files. You can override this behavior by setting
`NETBOOT_DIR` and `NFS_DIR`, ie.:

```
NETBOOT_DIR=../my-netboot-dir NFT=../my-nfs ./init.sh
```

By default if no `NETBOOT_DIR` set `init.sh` downloads Debian jessie netboot
package and extracts it to `../netboot`.

To check server status:

```
service tftpd-hpa status
```
If server is not running, it can be started using following command:

```
service tftpd-hpa start
```

For debugging purposes `tcpdump` can be used (displaying connection requests).

```
apt-get install tcp-dump
tcpdump
```

APU2 development and testing
----------------------------

For those who want to test APU2 I advise to use [3mdeb/netboot](https://github.com/3mdeb/netboot) configuration.
After finished `init.sh` as described above. Run:

```
git clone https://github.com/3mdeb/netboot.git apu2-netboot
rsync -r apu2-netboot ../netboot
```

Ready to use package can be found [here](http://3mdeb.com/netboot/netboot-20160627.tar.gz).
