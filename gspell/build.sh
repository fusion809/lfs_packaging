#!/bin/bash
set -e
name=gspell
version=$(gn_ver gspell)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(enchant gtk3 icu)
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D gtk_doc=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
