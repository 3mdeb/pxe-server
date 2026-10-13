#!/bin/bash
set -e
trap 'echo "ERROR: \"${BASH_COMMAND}\" failed with exit code $?" >&2' ERR

export_base="/srv/nfs/"
HTTP_SRV="/srv/http/"

### Handle `docker stop` for graceful shutdown
function shutdown {
    echo "- Shutting down nfs-server.."
    service nfs-kernel-server stop
    echo "- Nfs server is down"
    exit 0
}

trap "shutdown" SIGTERM
####

echo "Export points:"
echo "/srv/nfs *(rw,sync,fsid=0,no_subtree_check,no_root_squash)" | tee /etc/exports
echo "/srv/nfs/debian *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports
echo "/srv/nfs/xen *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports
echo "/srv/nfs/voyage *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports

read -a exports <<< "${@}"
for export in "${exports[@]}"; do
    src=`echo "$export" | sed 's/^\///'` # trim the first '/' if given in export path
    src="$export_base$src"
    mkdir -p $src
    chmod 777 $src
    echo "$src *(rw,sync,no_subtree_check,no_root_squash)" | tee -a /etc/exports
done

echo -e "\n- Initializing nfs server.."
mkdir -p /run/sendsigs.omit.d
# libtirpc in Jessie allocates per-fd tables sized by the open files limit and
# fails with "out of memory" on the huge default limit set by recent Docker
ulimit -n 1024
# rpcbind is not started here, the host's rpcbind is used instead (see start.sh)
# the host may already run its own rpc.statd registered with the shared rpcbind
if rpcinfo -u localhost 100024 >/dev/null 2>&1; then
    echo "- rpc.statd already running on the host, reusing it"
else
    # set static port to avoid using random ports by nfs
    rpc.statd --no-notify --port 32765 --outgoing-port 32766
fi
# force nfsv3 over udp due to TCP issues (investigating)
rpc.nfsd -V3 -N2 -N4 -d 8
rpc.mountd -V3 -N2 -N4 --port 32767
# update exports and start nfs server
exportfs -ra
service nfs-kernel-server start

echo "- Nfs server is up and running.."
cd $HTTP_SRV
python -m SimpleHTTPServer 8000
