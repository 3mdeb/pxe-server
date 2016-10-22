Install OpenBSD over PXE
------------------------

    1. Obtain necessary files.

Minimal set of files to perform network installation:

```
    bsd.rd
    pxeboot
```
For example:

```
    wget http://ftp.icm.edu.pl/pub/OpenBSD/5.9/amd64/bsd.rd
    wget http://ftp.icm.edu.pl/pub/OpenBSD/5.9/amd64/pxeboot
```
By default, those files should be placed directly in tftp server root
directory. In our case it's `netboot` directory, which is mounted inside
container at `/srv/tftp`. They can be also placed in different paths, such as
`/OpenBSD/amd64`, but it needs to be stated later in configuration files.

If only one system per server is concerned, you could directly boot using
`pxeboot` as `filename` variable. However, we are using `pxelinux ` and we are
interested in multiple systems. It is important to have the file end with .0,
because the extension determines what pxelinux does with the file. The .0 tells
pxelinux that it is a PXE image.

```
    mv pxeboot pxeboot.0
```
    2. Provide paths to files.

Originally, path to `pxeboot.0` should be entered in `pxelinux.cfg/default`
file. However, we have used debian installer boot  menu from
`/debian-installer/i386/boot-screens/` and simply imported it into
`pxelinux.cfg/default`:

```
    include debian-installer/i386/boot-screens/menu.cfg
```
Menu entry for OpenBSD is provided in `txt.cfg` file:

```
    label open-bsd
    	menu label ^OpenBSD-5.9
    	menu default
    	kernel OpenBSD/amd64/pxeboot.0
```
Path to `bsd.rm` is set in `/etc/boot.conf`, which needs to be created.

```
    boot tftp:/OpenBSD/amd64/bsd.rd
```
Note that it has to be in  tftpd root directory, not the directory where bsd
files are!

    3. Boot configuration.

Bootloader configuration is set through `/etc/boot.conf` file. In our case we
need at least to enable serial port communication and set it's speed.

```
    stty com0 115200
    set tty com0
```
    4. Installation.

Installation process is mostly straightforward. Take a look at the choice of
sets to install. Advised minimal sets are:

```
    bsd (the kernel) - essential
    bsd.rd (RAM disk kernel)
    bsd.mp (multi-processor kernel)
    baseXX.tgz (OpenBSD base system) - essential
```
There is a way to automate installation process by creating `install.conf` file.
