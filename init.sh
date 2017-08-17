#!/bin/bash

: ${NETBOOT_DIR:=./netboot}
docker build -t 3mdeb/pxe-server .

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to build container"
    exit 1
fi

docker run -p 69:69/udp --network=host -v ${PWD}/${NETBOOT_DIR}:/srv/tftp -t -i 3mdeb/pxe-server /bin/bash -c "bash /tftpdstart.sh;
/bin/bash" 
