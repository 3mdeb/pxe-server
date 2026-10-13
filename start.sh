#!/bin/bash

set -e

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to build container"
    exit 1
fi

docker run --rm --name pxeserver --privileged --network host \
	 -v /run/rpcbind.sock:/run/rpcbind.sock \
	 -v ${PWD}/netboot:/srv/http \
	 -v ${PWD}/debian/debian-stable:/srv/nfs/debian \
	 -v ${PWD}/voyage:/srv/nfs/voyage \
	 -v ${PWD}/xen:/srv/nfs/xen \
	 -t -i 3mdeb/pxe-server /bin/bash -c \
	 "bash /usr/local/bin/run.sh"


