#!/bin/bash

sed -i 's/secure/secure -c/' /etc/default/tftpd-hpa 
/etc/init.d/tftpd-hpa restart