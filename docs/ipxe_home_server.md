# iPXE on home server #

This guide is about setting up an iPXE-tftp server on home server machine.

## Installation ##

1. Server should be running inside a Docker container therefore docker is
required. To install docker go [here](https://docs.docker.com/engine/installation/).

2. To build environment and install ipxe server go to [this](https://github.com/3mdeb/pxe-server)
address and follow instructions. According to FHS, pxe-server should be cloned
to `/opt/pxe-tftpd/`. Note that this catalog is used later. It can be changed
but this requires changes in `ipxe-tftp.service` (if used).

3. Script `./init.sh` builds environment for Debian i386 installation. Note that
it creates two catalogs 'nfs' and 'netboot', then Debian i386 netboot installer
is downloaded and unpacked inside 'netboot'.

4. Inside container:
 - To run tftp server use `sudo service tftpd-hpa start`.  

To autostart tftp daemon Dockerfile should be modified with line at the
bottom:`ENTRYPOINT service tftpd-hpa start && bash`

## Autostart container ##

There are some ways to autostart container. We will use systemd. Configuration
file is provided: `ipxe-tftp.service` in current directory.

1. Copy configuration file to proper destination:  
`sudo cp ipxe-tftp.service /lib/systemd/system/`

2. Reload daemon:  
`sudo systemctl daemon-reload`

3. Start created service:  
`sudo systemctl start ipxe-tftp.service`

4. Check if our container is up:  
`sudo systemctl status ipxe-tftp.service`  
`sudo docker ps`

5. Set autostart:  
`sudo systemctl enable ipxe-tftp.service`

## Client usage example ##
```
iPXE> dhcp net0  
iPXE> set filename pxelinux.0
iPXE> set next-server <ip_address>
iPXE> chain tftp://${next-server}/${filename}
```
Note, that shortcut chain `tftp://<ip_address>/pxelinux.0` will not work and
will cause system hanging.

## Multiple systems booting ##

Booting multiple systems requires proper boot menu configuration and can be a
little tricky. There are several ways to do it but, as mentioned in OpenBSD doc,
we are using Debian boot menu and adding desired options. This example covers
multiple versions of Debian but it can be easily done for other systems using
the same pattern.

#### Folder structure ####

In default (after using `init.sh` script) folder structure is a result of
unpacking debian netboot tarball in netboot folder:

```
.
├── debian-installer
│   └── i386
├── ldlinux.c32 -> debian-installer/i386/boot-screens/ldlinux.c32
├── pxelinux.0 -> debian-installer/i386/pxelinux.0
├── pxelinux.cfg -> debian-installer/i386/pxelinux.cfg
└── version.info
```
For multiple systems following folder structure is proposed:
```
.
├── debian-installer
│   ├── stable
│   │   ├── amd64
│   │   └── i386
│   └── unstable
│       ├── amd64
│       └── i386
├── ldlinux.c32 -> debian-installer/stable/amd64/boot-screens/ldlinux.c32
├── pxelinux.0 -> debian-installer/stable/amd64/pxelinux.0
├── pxelinux.cfg -> debian-installer/stable/amd64/pxelinux.cfg/
└── version.info
```
Note, that after making changes symbolic links will be broken and will
need refreshing.

#### Boot menu config ####

Two files needs to be edited by modifying file paths inside:
- `debian-installer/stable/i386/pxelinux.cfg/default`
- `debian-installer/stable/i386/boot-screens/menu.cfg`

Then we need to add additional options in menu:
- `debian-installer/stable/i386/boot-screens/txt.cfg`

Pattern:

```
label install
        menu label ^Install <system-title>
        kernel <kernel-path>
        append vga=788 initrd=<initrd.gz-path> <options>        
```

During the modification of `txt.cfg` it is possible to modify kernel booting
parameters. To make installer available on serial console add:
`console=ttyS0,115200n8`

## Known issues ##

#### Network jailing ####

In default, Docker container cannot be accessed from outside world. To overcome
this problem: `--net=host` parameter has been used.

There surely are more sophisticated methods. To read more go to [docker site](https://docs.docker.com/engine/userguide/networking/default_network/binding/).

#### TFTP vulnerability ####

TFTP protocol is based on UDP therefore it very much relies on link stability.
Transmission can be easily disrupted which immediately stops booting process.
Best practice is to connect ipxe client and server to one node (router).
