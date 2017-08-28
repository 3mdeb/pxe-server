pxe-server
==========

This repository contains PXE server that should help in installing, testing and
developing operating systems and firmware for PXE-capable platforms.

It was inspired by effort required to test PC Engines apu2 platform.

Usage
-----

```
git clone https://github.com/3mdeb/pxe-server.git
cd pxe-server
CLOUD_USER=<cloud-username> NFS_SRV_IP=<server-ip> ./init.sh
```

APU2 development and testing
----------------------------

## Prepare iPXE
`init.sh` script used above initializes directories, downloads PXE from Debian
netboot, voyage netinst image and Debian 8 Jessie rootfs. It also clones the
3mdeb netboot [repo](https://github.com/3mdeb/netboot.git)

It is necessary to load nfs kernel modules before building a container:
```
modprobe nfs
modprobe nfsd
modprobe nfsv3
```
Then just build and run the container by running following script in
`pxe-server` directory:

```
./start.sh
```

Everything is ready now to boot APU2 over network.

## Booting iPXE on recent firmware

This instruction assume you do not provide information about TFTP server over
DHCP.

Boot to iPXE and type:

```
iPXE> dhcp net0
iPXE> set filename pxelinux.0
iPXE> set next-server <server-ip>
iPXE> chain tftp://${next-server}/${filename}
```

## Finishing work with nfs server

To stop the container, simply run it in `pxe-server` directory:
```
./stop.sh
```
To rebuild the container, it has to be stopped first, because it is named.

## Robot Framework

Some automation of above process was mage. Relevant source code can be found
[here](https://github.com/pcengines/apu-test-suite)>
