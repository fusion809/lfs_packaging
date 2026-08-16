#!/bin/bash
name=libtool
version=$(gnu_ver $name)
lfs_depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"

if ! [[ -f $filename ]]; then
	wget -c https://ftp.gnu.org/gnu/libtool/$filename
fi

tar xf $filename
cd "$direname"
cmi --prefix=/usr
sudo rm -fv /usr/lib/libltdl.a
cd ..
echo "$version" > /var/lib/custom-packages/$name
