#!/bin/bash
set -e
name=which
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://mirror.freedif.org/pub/blfs/development/w/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
