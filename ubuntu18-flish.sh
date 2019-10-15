#!/bin/bash
set -e

function error {
    echo -e $* >&2
}

OPTS=`getopt -o hd:p: -l help,dist:,password:,jwt: -- "$@"`

if [ $? != 0 ] ; then error "Failed parsing options." ; exit 1 ; fi

eval set -- "$OPTS"

DIST=xenial
PASSWD=rooter
JWT=
HELP=0

while true; do
  case "$1" in
    -h | --help )     HELP=1; shift ;;
    -d | --dist )     DIST="$2"; shift; shift ;;
    -p | --password ) PASSWD="$2"; shift; shift ;;
    --jwt ) JWT="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$HELP" == "1" ]
    then
    error Usage: $0 [OPTION]...
    error "\t-h\tprint this message"
    error "\t-d\tselect the ubuntu version, default to 'xenial'"
    error "\t-p\tset the root password, default to 'rooter'"
    error "\t--jwt\tIYO JWT token to upload the image to the hub, skip upload if not given"
    exit 1
fi

if [ "$UID" != "0" ]
    then
    error "must be root"
    exit 1
fi

ROOT=$DIST

debootstrap $DIST $ROOT http://ftp.belnet.be/ubuntu.com/ubuntu

mount -o bind /proc $ROOT/proc
mount -o bind /dev $ROOT/dev
mount -o bind /sys $ROOT/sys

function _cleanup {
    umount $ROOT/proc
    umount $ROOT/dev
    umount $ROOT/sys
}

trap _cleanup INT QUIT TERM EXIT

# we need to install the kernel now in chroot
cp /etc/apt/sources.list $ROOT/etc/apt/sources.list

cat > $ROOT/etc/initramfs-tools/modules <<EOF
9p
9pnet
9pnet_virtio
9pnet_rdma
EOF

cat > $ROOT/etc/fstab <<EOF
root	/	9p	rw,cache=loose,trans=virtio	0 0
EOF

cat > $ROOT/etc/locale.gen <<EOF
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
EOF

# interface name is always eth0
cat > $ROOT/etc/netplan/ens4.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens4:
      dhcp4: true
      dhcp6: true
EOF

cat > $ROOT/setup.sh <<EOF
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin

locale-gen
apt-get update
apt-get install -y --allow-unauthenticated --no-install-recommends linux-generic
update-initramfs -u

KERNEL=\`ls /boot/vmlinuz-*\`
INITRD=\`ls /boot/initrd.img-*\`
cat > /boot/boot.yaml <<INEOF
kernel: \${KERNEL}
initrd: \${INITRD}
cmdline: net.ifnames=0 biosdevname=0
INEOF

echo "root:${PASSWD}" | chpasswd
EOF

chroot $ROOT /bin/bash /setup.sh

#EXTRA CONFIG
cat > $ROOT/setup.sh <<EOF
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/bin:/usr/bin:/usr/local/bin

apt-get install -y openssh-server
EOF

chroot $ROOT /bin/bash /setup.sh

rm $ROOT/setup.sh
#rm -rf $ROOT/var/cache/apt/*

_cleanup
trap - INT QUIT TERM EXIT

FNAME=ubuntu-${DIST}.tar.gz
pushd $ROOT
echo "Archiving ..."
tar -czf ../${FNAME} .
popd

if [ "${JWT}" != "" ]
then
    echo "Uploading image to hub..."
    curl -b "caddyoauth=${JWT}" -F file=@${FNAME} https://hub.gig.tech/api/flist/me/upload
else
    echo "No JWT token is given, skipping upload"
fi
echo "Done"
