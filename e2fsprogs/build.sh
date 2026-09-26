#!/bin/bash
set -e
name=e2fsprogs
homepage="http://e2fsprogs.sourceforge.net"
description="Ext2/3/4 filesystem utilities"
version=$(sf_ver $name/$name)
depends=(bash coreutils gcc glibc gzip make tar wget)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "v$version" "$filename"
unpk_enter "$filename" "$direname"
mkdir -v build
cd       build
../configure --prefix=/usr       \
             --sysconfdir=/etc   \
             --enable-elf-shlibs \
             --disable-libblkid  \
             --disable-libuuid   \
             --disable-uuidd     \
             --disable-fsck
maki
sudo su -c "rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info"
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
