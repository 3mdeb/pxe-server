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
  wget http://ftp.icm.edu.pl/pub/OpenBSD/6.1/amd64/SHA256
  wget http://ftp.icm.edu.pl/pub/OpenBSD/6.1/amd64/SHA256.sig
  ```
  You can verify the signature using `signify`(1):
  `signify -C -p /etc/signify/openbsd-61-base.pub -x SHA256.sig`
  You can also verify the SHA256 hash:
  `sha256 -c f9c2ca96c7fb93d343b4e70ce55ff09fc927f1a0664597170ef408c5a1f398c0 pxeboot`
  `sha256 -c 257270c76ecd9bcbf2b2093db1ad04483e85909a6207e3c769be176d3c489e7b bsd.rd`
  
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
  	menu label ^OpenBSD-6.1
  	menu default
  	kernel OpenBSD/amd64/pxeboot.0
  ```
  
  Note that it has to be in tftpd root directory, not the directory where bsd
  files are!
  
  If you don't want to use DHCP, you can use the following commands in iPXE:
  ```
  iPXE> ifopen net0
  iPXE> set net0/ip 192.168.0.100
  iPXE> set net0/netmask 255.255.255.0
  iPXE> set net0/gateway 192.168.0.1  
  iPXE> chain tftp://192.168.0.1/auto_install
  ```
  You need to adjust IP's and netmask to your own environment.
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

The binary you set to load in "filename" directive in DHCP server needs to
point to `pxeboot`. Example:

```
subnet 192.168.0.0 netmask 255.255.255.0 {
        option routers 192.168.0.1;
        range 192.168.0.4 192.168.0.254;
        filename "pxeboot";
```        
You will be asked after booting:
```
Could not determine auto mode.
Response file location? [http://192.168.1.1/install.conf]
The configuration file for installation is served by HTTP server passed by
`server-name`, `option tftp-server-name`, or `next-server` directive.
```

If the location is true, press Enter.
The file needs to be named `install.conf`. Here's an example:
```
System hostname = 3mdeb.dev
Change the default console to com0 = yes
Which speed should com0 use = 115200
Password for root = 3mdeb.dev
Network interfaces = em0
IPv4 address for em0 = dhcp
Setup a user = emdeb
Password for user = 3mdeb.dev
What timezone are you in = Europe/Warsaw
Location of sets = http
Server = mirror.leaseweb.com
Use Whole disk MBR, whole disk GPT, OpenBSD area or Edit = W
```

You need to place it in HTTP root.

You need to connect APU to the em0 Ethernet port (the nearest port to the RS232
plug) and provide apriopriate routing and DNS resolver.
