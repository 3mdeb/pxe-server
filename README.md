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

Following procedure assume deployment on clean Debian system:

```
ansible-playbook -i "<target_host>," -b --ask-become-pass pxe-server.yml
```


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

