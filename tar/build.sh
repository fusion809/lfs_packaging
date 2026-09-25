#!/bin/bash
set -e
name=tar
homepage="https://www.gnu.org/software/tar/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
patch_filename=$(pfile $name)
depends=(acl gcc glibc make tar wget xz)
gnu_download $name $filename
download_src "https://www.linuxfromscratch.org/patches/lfs/development/$patch_filename"
unpk_enter "$filename" "$direname"
patch -Np1 -i ../$patch_filename
FORCE_UNSAFE_CONFIGURE=1  \
cmi --prefix=/usr
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
