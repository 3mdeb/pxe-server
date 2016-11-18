# iPXE on home server #

This guide is about setting up an iPXE-tftp server on home server machine.

## Installation ##

1. Server should be running inside a Docker container therefore docker is
required. To install docker on Debian go [here](https://docs.docker.com/engine/installation/linux/debian/).

2. To build environment and install ipxe server go to [this](https://github.com/3mdeb/pxe-server)
address and follow instructions. I belive that according to FHS, pxe-server
should be cloned to `/opt/pxe-tftpd/`. Note that this catalog is used later. It
can be changed but this requires changes in `ipxe-tftp.service` (if used).

3. Script `./init.sh` builds environment for Debian i386 installation.

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

## Known issues ##

#### Network jailing ####

In default, Docker container cannot be accessed from outside world. To overcome
this problem: `--net=host` has been used. Then to run container: `./init.sh`.

There surely are more sophisticated methods. To read more go to [docker site](https://docs.docker.com/engine/userguide/networking/default_network/binding/).

#### TFTP vulnerability ####

TFTP protocol is based on UDP therefore it very much relies on link stability.
Transmission can be easily disrupted which immediately stops booting process.
Best practice is to connect ipxe client and server to one node (router).
