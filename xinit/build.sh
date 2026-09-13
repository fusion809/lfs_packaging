#!/bin/bash
set -e
name=xinit
version=$(xfd_ver $name)
depends=(glibc libX11 libXau libXdmcp libxcb)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.x.org/pub/individual/app/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --with-xinitdir=/etc/X11/app-defaults
cd ../
sudo ldconfig
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
