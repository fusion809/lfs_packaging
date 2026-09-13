#!/bin/bash
set -e
name=libxcvt
version=$(xfd_ver $name)
depends=(glibc)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.x.org/pub/individual/lib/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
