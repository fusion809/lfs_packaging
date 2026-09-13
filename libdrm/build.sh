#!/bin/bash
set -e
name=libdrm
repo=Distrotech/$name
version=$(gh_ver $repo)
depends=(glibc libpciaccess zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://dri.freedesktop.org/libdrm/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr \
            --buildtype=release   \
            -D udev=true          \
	    -D valgrind=disabled)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
