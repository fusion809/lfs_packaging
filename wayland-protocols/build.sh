#!/bin/bash
name=wayland-protocols
version=$(wget -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
blfs_depends=(wayland)
filename="$name-$version.tar.xz"
direname="$name-$version"
URL="https://gitlab.freedesktop.org/wayland/$name/-/releases/$version/downloads/$filename"
if ! [[ -f "$filename" ]]; then
	wget -c $URL 
fi

tar xf $filename
cd $direname
mkdir build &&
cd    build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release &&
ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
