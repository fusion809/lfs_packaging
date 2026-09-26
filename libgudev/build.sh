#!/bin/bash
set -e
name=libgudev
homepage="https://gitlab.gnome.org/GNOME/libgudev"
description="GObject bindings for libudev"
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libffi pcre2 systemd)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
