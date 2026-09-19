#!/bin/bash
set -e
name=libgtop
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libXau pcre2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --disable-static)
cmi "${options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
