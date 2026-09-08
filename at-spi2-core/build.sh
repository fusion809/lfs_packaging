#!/bin/bash
set -e
name=at-spi2-core
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(dbus glib2 glibc libX11 libXau libXdmcp libXext libXi libXres libXtst libffi libxcb pcre2 systemd util-linux zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D gtk2_atk_adaptor=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
