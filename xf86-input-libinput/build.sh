#!/bin/bash
set -e
name=xf86-input-libinput
version=$(xfd_ver $name)
depends=(glibc libevdev libinput lua mtdev systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.x.org/pub/individual/driver/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
