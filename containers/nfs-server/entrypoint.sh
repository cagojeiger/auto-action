#!/bin/sh
set -e

EXPORT_DIR="${NFS_EXPORT_DIR:-/export}"
ALLOWED_CLIENTS="${NFS_ALLOWED_CLIENTS:-*}"
NFS_OPTIONS="${NFS_OPTIONS:-rw,sync,no_subtree_check,no_root_squash,fsid=0}"

modprobe nfsd || true
mount -t nfsd nfsd /proc/fs/nfsd 2>/dev/null || true

echo "${EXPORT_DIR} ${ALLOWED_CLIENTS}(${NFS_OPTIONS})" >/etc/exports

rpcbind -w
exportfs -a
rpc.nfsd
rpc.mountd --foreground
