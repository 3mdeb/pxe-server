pxe-server
==========

This repository contains PXE server that should help in installing, testing and
developing operating systems and firmware for PXE-capable platforms.

It was inspired by effort required to test PC Engines apu2 platform.

`./init.sh` builds container and runs it exposing port 69. There is silent
assumption that your host doesn't have port 69 in use.

Usage
-----

`init.sh` assumes that netboot directory is `./netboot` or provide it as a
variable `NETBOOT`.


```
git clone https://github.com/miczyg1/pxe-server.git
git checkout diskless-netboot
./init.sh [NETBOOT=/path/to/netboot/dir]
```

APU2 development and testing
----------------------------

## Prepare iPXE

You have to provide PXE bootloader from any debian-like system netboot
installation.

Copy the `menu.cfg` and `syslinux.cfg` in correct directory. Do not forget to
change nfsroot path and nfsroot server ip.

## Prepare NFSroot

`USERNAME` is a user name to be created for login.

Example:
```
./create_rootfs.sh NFSROOT=/path/to/nfs/root USERNAME=name
```

This script will create nfsroot file system, install necessary packages and
configure exports. 

## Preparing kernel for netboot with NFS support

It is necessary to prepare a proper kernel image with nfs support. I compiled a
4.8.5 kernel. Binary is in `netboot` directory and config in `kernel` directory.
This kernel image should be placed in `netboot`. Otherwise changes in `menu.cfg`
should be made.

## Booting iPXE on recent firmware

This instruction assume you do not provide information about TFTP server over
DHCP.

Boot to iPXE and type:

```
iPXE> dhcp net0
iPXE> set filename pxelinux.0
iPXE> set next-server 192.168.0.106
iPXE> chain tftp://${next-server}/${filename}
```

## Preparing flashrom

When the system is booted it is time to get `flashrom`:

```
git clone https://github.com/flashrom/flashrom.git
cd flashrom
sudo make install
```

