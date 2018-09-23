pxe-server
==========

This repository contains PXE server (TFTP+NFS) that should help in installing,
testing and developing operating systems and firmware for PXE-capable
platforms.

It was inspired by effort required to test PC Engines apu2 platform.

We use PXE server without DHCP, what may cause problems to BSD systems and is
subject of our further work on this project.

Usage
-----

# pxe-server deployment

## Ansible setup

```
virtualenv ansible-venv
source ansible-venv/bin/activate
pip install ansible
ansible-galaxy install angstwad.docker_ubuntu
ansible-galaxy install debops.apt_preferences
ssh-keygen -f ~/.ssh/ansible
ssh-add ~/.ssh/ansible
ssh-copy-id -i ~/.ssh/ansible <user>@<target_host>
```

## Initial deployment

### Rootfs components creation

```
docker run --privileged --rm -v $HOME/.ansible:/root/.ansible  \
-v $HOME/.ccache:/home/debian/.ccache \ -v $PWD:/home/debian/scripts \
-t -i 3mdeb/debian-rootfs-builder ansible-playbook -vvv \ -i hosts \
/home/debian/scripts/create-rootfs-components.yml
```

### Rootfs preparation

```
docker run --privileged --rm -v $HOME/.ansible:/root/.ansible  \
-v $HOME/.ccache:/home/debian/.ccache \ -v $PWD:/home/debian/scripts \
-t -i 3mdeb/debian-rootfs-builder ansible-playbook -vvv \ -i hosts \
/home/debian/scripts/prepare_rootfs.yml
```

### Deploy

Following procedure assume deployment on clean Debian as target system:

```
ansible-playbook -i "<target_host>," -b --ask-become-pass pxe-server.yml
```

### Tests

`v1.0.0` tests results:

| Description | Result |
| --- | --- |
| Boot Xen 4.8 and Verify if IOMMU is enabled | FAIL |
| Boot Xen 4.8 and Verify if IOMMU is enabled on Linux development kernel | FAIL |
| Boot Xen development kernel and Linux 4.14.y | PASS |
| Boot to Core 6.4 booted over iPXE | FAIL |
| Voyage installation | FAIL |
| Ubuntu installation | PASS |
| Debian i386 installation | FAIL |
| Debian installation | PASS |
| pfSense 2.4.x installation | FAIL |

Test duration: ~2h15min

### Performance

```
Tuesday 21 August 2018  17:47:35 +0200 (0:00:00.820)       0:05:09.644 ********
===============================================================================
apt ------------------------------------------------------------------- 136.75s
copy ------------------------------------------------------------------- 63.61s
docker ----------------------------------------------------------------- 51.06s
unarchive -------------------------------------------------------------- 36.18s
get_url ---------------------------------------------------------------- 10.50s
netboot ----------------------------------------------------------------- 4.56s
setup ------------------------------------------------------------------- 2.49s
file -------------------------------------------------------------------- 2.33s
mount ------------------------------------------------------------------- 0.91s
command ----------------------------------------------------------------- 0.82s
debops.apt_preferences -------------------------------------------------- 0.25s
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
total ----------------------------------------------------------------- 309.46s
Tuesday 21 August 2018  17:47:35 +0200 (0:00:00.820)       0:05:09.633 ********
===============================================================================
apt : Install essential packages --------------------------------------- 99.51s
Copy Debian rootfs ----------------------------------------------------- 59.49s
docker : Start 3mdeb/pxe-server Docker container ----------------------- 35.68s
Unarchive Debian rootfs ------------------------------------------------ 31.32s
apt : Remove cdrom repo ------------------------------------------------ 12.19s
docker : Install docker ------------------------------------------------ 10.67s
Get Voyage ------------------------------------------------------------- 10.50s
apt : Add trffic manager stable deb repo -------------------------------- 8.19s
apt : Add trffic manager stable deb-src repo ---------------------------- 6.65s
Unarchive Voyage -------------------------------------------------------- 4.86s
apt : Add Docker repo --------------------------------------------------- 4.47s
apt : Add Docker CE key to apt ------------------------------------------ 4.02s
docker : Install docker-py ---------------------------------------------- 3.88s
Gathering Facts --------------------------------------------------------- 2.49s
Copy Linux 4.14.y ------------------------------------------------------- 2.24s
Copy Linux 4.9.y -------------------------------------------------------- 1.88s
apt : Install apt-transport-https --------------------------------------- 1.73s
netboot : deploy menu.ipxe ---------------------------------------------- 1.43s
netboot : copy preseed.cfg ---------------------------------------------- 1.04s
Create /var/voyage ------------------------------------------------------ 1.01s
Playbook run took 0 days, 0 hours, 5 minutes, 9 seconds
```

====


`init.sh` downloads all necessary files, OS images, PXE and extracts them in
proper directories.

> `init.sh` script uses our netboot repository by default. It is the repository it
> should be paired with.

Please note that `init.sh` also download prepared Debian boot images. In root
directory of those images you can find `CHANGELOG` document which briefly
describe modifications.

APU2 development and testing
----------------------------

### Setting up docker container

In order to set up isolated environment for pxe-server with nfs-server and
http-boot, just run:

```
./start.sh
```

This script builds a container and runs it with correct configuration
nfs-kernel-server.

`run.sh` is a script that runs at container startup, do not use it on Your host
PC.

## Chainloading over HTTP

In some situation it may happen that TFTP server may be unreliable. There are
known network configurations where routers filter tftp traffic. Because of that
we decided to switch over to HTTP.

Boot to iPXE and type:

```
iPXE> ifconf net0
iPXE> dhcp net0
iPXE> chain http://<http-server-ip>:8000/menu.ipxe
```

Of course please replace `<http-server-ip>` with address provided during
initialization (`NFS_SRV_IP`).

### Select options

Currently supported options are:

1. `Debian stable netboot` - it is a Debian Stretch rootfs served over nfs with custom
kernel
2. `Voyage netinst` - a Voyage Linux network installation image
3. `Debian stable netinst` - runs a Debian stable amd64 network installation from external repository
4. `Debian testing netinst` - runs a Debian testing amd64 network installation from external repository

The credentials for Debian stable netboot are as follows:
login: root
password: debian

Those credentials are visible during boot:

```
Debian GNU/Linux 9 apu2 ttyS0 [root:debian]

apu2 login: 
```

## Robot Framework

Some automation of above process has been prepared. Relevant source code can be
found [here](https://github.com/pcengines/apu-test-suite)


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
