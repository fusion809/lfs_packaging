#!/bin/bash
name=e2fsprogs
version=$(sf_ver $name/$name)
lfs_depends=(gcc make glibc tar gzip coreutils bash wget)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/project/$name/$name/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
echo "$version" > /var/lib/custom-packages/$name
