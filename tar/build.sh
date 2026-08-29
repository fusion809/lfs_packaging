#!/bin/bash
set -e
name=tar
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
patch_filename=$(pfile $name)
lfs_depends=(acl gcc glibc make tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi

if ! [[ -f $patch_filename ]]; then
	wget -c https://www.linuxfromscratch.org/patches/lfs/development/$patch_filename
fi
rm -rf $direname
tar xf $filename
cd $direname
patch -Np1 -i ../$patch_filename
FORCE_UNSAFE_CONFIGURE=1  \
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
