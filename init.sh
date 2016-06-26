#!/bin/bash

NETBOOT_URL=http://ftp.nl.debian.org/debian/dists/jessie/main/installer-i386/current/images/netboot/netboot.tar.gz
NETBOOT_DIR=netboot
NETBOOT_TAR=netboot.tar.gz

if [ ! -d  $NETBOOT_DIR ]; then
	mkdir -p $NETBOOT_DIR
	wget $NETBOOT_URL
	tar xvf $NETBOOT_TAR -C $NETBOOT_DIR
	rm $NETBOOT_TAR
fi

docker build -t 3mdeb/pxe-server .

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to build container"
    exit 1
fi

docker run -p 0.0.0.0:69:69/udp -v ${PWD}/${NETBOOT_DIR}:/srv/tftp -t -i 3mdeb/pxe-server
