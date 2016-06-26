This repository contain PXE server that should help in installing, testing and
developing operating system and firmware for PXE-capable platforms.

It was inspired by effort required to test PC Engines APU2 platform.

Server runs builds and run as Docker container which expose port 69. There is
silent assumption that you host doesn't have port 69 used.

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
