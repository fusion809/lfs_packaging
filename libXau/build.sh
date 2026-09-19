#!/bin/bash
set -e
name=libXau
version=$(xfd_ver $name)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.x.org/pub/individual/lib/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
