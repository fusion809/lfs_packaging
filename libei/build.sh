#!/bin/bash
set -e
name=libei
repo=libinput/$name
version=$(gfd_ver $repo)
depends=(glibc libevdev libxkbcommon systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://gitlab.freedesktop.org/$repo/-/archive/$version/$filename
fi
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D tests=disabled
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
