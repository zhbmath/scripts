#!/bin/bash
#Author: written by hbzhao

set -e
#clear
DIR_CURR=$(cd $(dirname "$0"); pwd)
cd $DIR_CURR

while getopts "a:b:c:d:f:hm:n:r:s:t:" arg; do
    case $arg in
     a) a=$OPTARG ;;
     b) b=$OPTARG ;;
     c) c=$OPTARG ;;
     d) d=$OPTARG ;;
     f) f=$OPTARG ;;
     h) echo "Usages: "
        echo "  -a app_name -b build_number -n iso_name -r rescan_packages -s scp_directory ;" exit 0  ;;
     m) m=$OPTARG ;;
     n) n=$OPTARG ;;
     r) r=$OPTARG ;;
     s) s=$OPTARG ;;
     t) t=$OPTARG ;;
     ?) echo "Unknown argument"; exit 1; ;;
    esac
done
shift $(($OPTIND - 1))

function set_env() {
    [ x$a != x ] && APP=$a || APP=test-server
    [ x$b != x ] && BUILD=$b || BUILD=1
    [ x$c != x ] && ARCH=$c || ARCH=amd64
    [ x$d != x ] && DATE=$d || DATE=$(date +%Y%m%d)
    [ x$f != x ] && SUFFIX=$f || SUFFIX=iso
    [ x$m != x ] && MAKE=$m || MAKE=1
    [ x$n != x ] && ISO_NAME=$n || ISO_NAME="${APP}_${DATE}_${ARCH}.iso"
    [ x$r != x ] && RESCAN=$r || RESCAN=1
    [ x$s != x ] && SCP_DIR=$s || SCP_DIR="root@192.168.10.68:/home/download/1.0.3/rcbuild/host-iso"
    [ x$t != x ] && TEST=$t || TEST=1
}

function make_iso() {
    [ -f new.iso ]  && rm new.iso
    cd ./iso
    [ $RESCAN -eq 1 ] || dpkg-scanpackages pool/main/ |gzip -9 > dists/stable/main/binary-amd64/Packages.gz
    find . -type f -exec md5sum {} + > ./md5sum.txt
    cd -
    genisoimage -quiet -V "New" -J -R -r -l -cache-inodes -b isolinux/isolinux.bin -c isolinux/boot.cat -boot-load-size 4 -boot-info-table -no-emul-boot \
    -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -o new.iso ./iso
    isohybrid --uefi new.iso
}

function test_iso() {
    [ -f test01.qcow2 ] && rm -f test01.qcow2
    [ -f test01.qcow2 ] || qemu-img create -f qcow2 test01.qcow2 800G  
    qemu-system-x86_64 -enable-kvm -name test01 \
    -boot cd -cdrom new.iso \
    -m 120024 -smp 4,sockets=1,cores=2,threads=2 \
    -hda test01.qcow2 \
    -usb -usbdevice tablet -localtime \
    -sdl \
    &   
}

function push_iso() {
    [ -f new.iso ] && scp new.iso ${SCP_DIR}/${ISO_NAME}
    ssh ${SCP_DIR%%:*} "cd ${SCP_DIR##*:} ; [ -f ${ISO_NAME} ] && md5sum  ${ISO_NAME} | tee ${ISO_NAME}.txt"
}

set_env
[ $MAKE  -eq 1 ] || make_iso
[ $TEST  -eq 1 ] || test_iso
[ $BUILD -eq 1 ] || push_iso

