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
  wget http://ftp.icm.edu.pl/pub/OpenBSD/6.1/amd64/bsd.rd
  wget http://ftp.icm.edu.pl/pub/OpenBSD/6.1/amd64/pxeboot
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
  
  Note that it has to be in  tftpd root directory, not the directory where bsd
  files are!
  
3. Boot configuration.

  OpenBSD bootloader by default loads `bsd` file, so rename `bsd.rd` to `bsd`.

4. Installation.

  Installation process is mostly straightforward. Take a look at the choice of
  sets to install. Advised minimal sets are:

  ```
  bsd (the kernel) - essential
  bsd.rd (RAM disk kernel)
  bsd.mp (multi-processor kernel)
  baseXX.tgz (OpenBSD base system) - essential
  ```

5. In order to use Autoinstall mode, a few more adjustments need to be made.

The binary you set to load in "filename" directive in DHCP server needs to point to "auto_install". Example:
```
subnet 192.168.0.0 netmask 255.255.255.0 {
        option routers 192.168.0.1;
        range 192.168.0.4 192.168.0.254;
        filename "auto_install";
```        

Otherwise, you're going to be asked whether you want to install or upgrade.

The configuration file for installation is served by HTTP server passed by `server-name`, `option tftp-server-name`, or `next-server` directive. The file needs to be named `install.conf`. Here's an example:
```
System hostname = 3mdeb.dev
Change the default console to com0 = yes
Which speed should com0 use = 115200
Password for root = dupa
Network interfaces = em0
IPv4 address for em0 = dhcp
Setup a user = emdeb
Password for user = dupa
What timezone are you in = Europe/Warsaw
Location of sets = http
Server = mirror.leaseweb.com
Use Whole disk MBR, whole disk GPT, OpenBSD area or Edit = W
```

You need to connect APU to the em0 Ethernet port (the nearest port to the RS232 plug) and provide apriopriate routing and DNS resolver.
