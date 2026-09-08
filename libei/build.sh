#!/bin/bash
set -e
name=libei
repo=libinput/$name
version=$(gfd_ver $repo)
depends=(glibc libevdev libxkbcommon systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/$repo/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release -D tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
