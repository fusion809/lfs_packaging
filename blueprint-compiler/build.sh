#!/bin/bash
set -e
name=blueprint-compiler
homepage="https://gnome.pages.gitlab.gnome.org/blueprint-compiler/"
description="Markup language and compiler for GTK 4 user interfaces"
version=$(gn_ver $name)
depends=(pygobject)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
