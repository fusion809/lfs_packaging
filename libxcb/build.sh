#!/bin/bash
set -e
name=libxcb
version=$(xfd_ver $name)
depends=(glibc xcb-proto libXau libXdmcp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://xorg.freedesktop.org/archive/individual/lib/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --without-doxygen --docdir=/usr/share/doc/$direname
LC_ALL=en_US.UTF-8 maki
sudo su -c "chown -Rv root:root /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
