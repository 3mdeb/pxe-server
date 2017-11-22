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
NFS_SRV_IP=<host-pc-ip> ./init.sh
```

`init.sh` downloads all necessary files, OS images, PXE and extracts them in
proper directories.

> `init.sh` script uses our netboot repository by default. It is the repository it
> should be paired with.

APU2 development and testing
----------------------------

### Setting up docker container

In order to set up isolated environment for pxe-server with nfs-server and
tftp-boot, just run:

```
./start.sh
```

This script builds a container and runs it with correct configuration of tftpd
and nfs-kernel-server.

`run.sh` is a script that runs at container startup, do not use it on Your host
PC.

### Booting iPXE on recent firmware

This instruction assume you do not provide information about TFTP server over
DHCP.

Boot to iPXE and type:

```
iPXE> ifconf net0
iPXE> dhcp net0
iPXE> set filename pxelinux.0
iPXE> set next-server <tftpboot-server-ip>
iPXE> chain tftp://${next-server}/${filename}
```

### Select options

Currently supported options are:

1. `Debian-netboot` - it is a Debian Stretch rootfs served over nfs with custom
kernel
2. `Voyage-netinst` - a Voyage Linux network installation image
3. Debian `Install` - runs a Debian i386 network installation

The credentials for Debian Stretch are as follows:
login: root
password: root

## Robot Framework

Some automation of above process has been prepared. Relevant source code can be
found [here](https://github.com/pcengines/apu-test-suite)

## Chainloading over HTTP

In some situation it may happen that TFTP server may be unreliable. There are
known network configurations where routers filter tftp traffic. Simple
workaround for that can be, instead of using above mentioned tftp server, try
to use HTTP.

Below example show how to netboot Debian installed with
`NFS_SRV_IP=<host-pc-ip> ./init.sh` command.

Go to `pxe-server` directory and run HTTP server:

```
python3 -m http.server
```

Boot to iPXE and type:

```
iPXE> ifconf net0
iPXE> dhcp net0
iPXE> chain http://${next-server}:8000/debian-netboot.ipxe
```

## Issues

I have encountered issues with network interface configuration. The
configuration is retrieved from DHCP 3 times:

1. In iPXEshell
2. Before nfs mount during boot time
3. At system startup (defined in /etc/network/interfaces)

> 1 and 2 are necessary, 3 is only needed to get internet connection on booted
system.

Requesting configuration that many times makes a little mess, so as a temporary
workaround add a static IP for the `net0/eth0` interface on Your DHCP server.
The IP address requested will remain the same and so the problems will be gone
too.

