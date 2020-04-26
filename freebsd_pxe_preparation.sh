#!/bin/bash -x

PXE_SERVER=${PXE_SERVER:-"root@192.168.0.15"}
FREEBSD_VER="11.3"
ISO_URL_BASE=https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/${FREEBSD_VER}
ISO_URL=${ISO_URL_BASE}/FreeBSD-${FREEBSD_VER}-RELEASE-amd64-memstick.img
ISO_SHA=${ISO_URL_BASE}/CHECKSUM.SHA256-FreeBSD-11.3-RELEASE-amd64
ISO_FILE_NAME=$(basename ${ISO_URL})
ISO_SHA_FILE_NAME=$(basename ${ISO_SHA})

# get xcp-ng image
[ ! -f ${ISO_FILE_NAME}  ] && wget ${ISO_URL}
[ ! -f ${ISO_SHA}  ] && rm -rf ${ISO_SHA_FILE_NAME}
wget ${ISO_SHA}

sha256sum_file=$(grep "(${ISO_FILE_NAME})" ${ISO_SHA_FILE_NAME} |cut -d" " -f4)
echo "${sha256sum_file} ./${ISO_FILE_NAME}"  | sha256sum -c || exit

# mount
[ ! -d isomount  ] && mkdir isomount
mountpoint isomount && sudo umount isomount
sudo losetup -Pf ${ISO_FILE_NAME}
sudo mount -t ufs -o ufstype=ufs2 /dev/loop0p5 isomount

scp -r isomount ${PXE_SERVER}:/tftpboot/freebsd-${FREEBSD_VER}

sudo losetup -D

# rsync with tftp
