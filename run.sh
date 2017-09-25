#!/bin/bash
set -e

export_base="/srv/nfs/"

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
mkdir /run/sendsigs.omit.d
rpcbind -i
# set static port to avoid using random ports by nfs
rpc.statd --no-notify --port 32765 --outgoing-port 32766
# force nfsv3 over udp due to TCP issues (investigating)
rpc.nfsd -V3 -N2 -N4 -d 8
rpc.mountd -V3 -N2 -N4 --port 32767
# update exports and start nfs server
exportfs -ra
service nfs-kernel-server start

echo "- Nfs server is up and running.."
# configure tftp
sed -i 's/TFTP_DIRECTORY=\"\/var\/lib\/tftpboot\"/TFTP_DIRECTORY=\"\/srv\/tftp\"/' /etc/default/tftpd-hpa
sed -i 's/secure/secure -c/' /etc/default/tftpd-hpa
/etc/init.d/tftpd-hpa start
