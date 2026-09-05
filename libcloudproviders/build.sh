#!/bin/bash
set -e
name=libcloudproviders
version=$(gn_ver libcloudproviders)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libffi pcre2 systemd util-linux zlib)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libcloudproviders/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
