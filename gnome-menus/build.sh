#!/bin/bash
set -e
name=gnome-menus
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi pcre2 systemd util-linux zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --sysconfdir=/etc \
            --disable-static)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
