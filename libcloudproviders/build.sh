#!/bin/bash
set -e
name=libcloudproviders
homepage="https://gitlab.gnome.org/GNOME/libcloudproviders"
description="DBus API that allows cloud storage sync clients to expose their services"
version=$(gn_ver libcloudproviders)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libffi pcre2 systemd util-linux zlib)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
