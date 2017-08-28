pxe-server
==========

This repository contains PXE server that should help in installing, testing and
developing operating systems and firmware for PXE-capable platforms.

It was inspired by effort required to test PC Engines apu2 platform.

`./init.sh` builds container and runs it exposing port 69. There is silent
assumption that your host doesn't have port 69 in use.

Usage
-----

```
git clone https://github.com/3mdeb/pxe-server.git
./init.sh
```

APU2 development and testing
----------------------------

## Prepare iPXE

For those who want to test apu2 I advise to use [3mdeb/netboot](https://github.com/3mdeb/netboot) configuration.
After finished `init.sh` as described above. Run:

```
git clone https://github.com/3mdeb/netboot.git
NETBOOT_DIR=./netboot ./init.sh
```

## Booting iPXE on recent firmware

This instruction assume you do not provide information about TFTP server over
DHCP.

Boot to iPXE and type:

```
iPXE> ifconf net0
iPXE> dhcp net0
iPXE> set filename pxelinux.0
iPXE> set next-server 192.168.0.106
iPXE> chain tftp://${next-server}/${filename}
```

## Robot Framework

Some automation of above process was mage. Relevant source code can be found [here](https://github.com/pcengines/apu-test-suite)>
