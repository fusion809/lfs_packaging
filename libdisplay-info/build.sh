#!/bin/bash
set -e
name=libdisplay-info
version=$(gfd_ver emersion/libdisplay-info)
direname="$name-$version"
filename="$direname.tar.xz"
blfs_depends=(hwdata)
lfs_depends=(glibc)

if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/emersion/libdisplay-info/-/releases/$version/downloads/$filename
fi
rm -rf "$direname"
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
