#!/bin/bash

set -e

docker build -t 3mdeb/pxe-server .

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to build container"
    exit 1
fi


docker run --rm --name pxeserver --privileged \
	 -p 111:111/tcp -p 2049:2049/tcp \
	 -p 627:627/tcp -p 627:627/udp -p 875:875/tcp -p 875:875/udp \
	 -p 892:892/tcp -p 892:892/udp -p 111:111/udp -p 2049:2049/udp \
	 -p 10053:10053/udp -p 10053:10053/tcp \
	 -p 32769:32769/tcp -p 32769:32769/udp \
	 -p 32765:32765/tcp -p 32765:32765/udp \
	 -p 32766:32766/tcp -p 32766:32766/udp \
	 -p 32767:32767/tcp -p 32767:32767/udp \
	 -v ${PWD}/netboot:/srv/http \
	 -v ${PWD}/debian:/srv/nfs/debian \
	 -v ${PWD}/voyage:/srv/nfs/voyage \
	 -t -i 3mdeb/pxe-server /bin/bash -c \
	 "bash /usr/local/bin/run.sh"


