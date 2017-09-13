Debian rootfs
=============

This paper describes procedure of creating a Debian rootfs for nfs server.

#### Requirements

1. Installed `debootstrap` package:
```
sudo apt-get install -y debootstrap
```
2. ~1GB free disk space.


## Creating base system

Choose a directory where the rootfs should be created, for example:
```
mkdir debian-rootfs
```

To create the base system run following command:

```
sudo debootstrap --foreign --arch <arch> <distro> debian-rootfs http://deb.debian.org/debian
```

For example:

```
sudo debootstrap --foreign --arch amd64 stretch debian-rootfs http://deb.debian.org/debian
```

Debootstrap must be run as super user in order to create files with correct
permissions etc. The command above will create basic file system and directories
and files. `debootstrap` has also a second stage which must be run inside
`chroot`. In order to finish creating filesystem run following command:

```
sudo chroot debian-rootfs
/debootstrap/debootstrap --second-stage --verbose
```

The creation of basic filesystem is done if there were no errors till now.

## Customizing created system

After debootstrapping the filesystem needs some configuration to satisfy the
needs. It is necessary to set up network interfaces, mounts and a root password.

Setting up network interfaces (inside chroot):

```
cat >> /etc/network/interfaces << EOF
auto lo
iface lo inet loopback
auto eth0
iface eth0 inet dhcp
EOF
```

Setting up mounts (inside chroot):

```
cat > /etc/fstab << EOF
/proc    /proc    proc    defaults   0 0
/sys     /sys     sysfs   defaults   0 0
EOF
```

Set root password (inside chroot):

```
passwd
```

## Package configuration

Probably You will want to install some packages, You can do it now inside chroot
by running:
```
apt-get install -y <package1> <package2> ...
```
or just boot the system with PXE and run it on target machine.

There is a guide how to setup pxe-server [here](README.md), but it is customized
for APU2.

### Packages for APU2

Install basic packages necessary for developer use (compiling from source,
coreboot etc.):

```
apt-get install -y nfs-common locales \
    sudo bc ssh ntpdate gettext \
    autoconf wpasupplicant dialog \
    makedev binutils apt-utils \
    git vim tmux python \
    ca-certificates \
    python-dev ntpdate \
    build-essential \
    iasl \
    m4 \
    flex \
    bison \
    gdb \
    doxygen \
    ncurses-dev \
    cmake \
    make \
    g++ \
    gcc-multilib \
    wget \
    liblzma-dev \
    zlib1g-dev
```

> You don't have to install them all if don't plan to do something big. Choose
> only the packages You will need.

For `flashrom` compilation these packages are necessary:

```
apt-get install -y libpci-dev libusb-dev \
    libusb-1.0-0-dev libftdi-dev
```