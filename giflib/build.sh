#!/bin/bash
set -e
name=giflib
homepage="https://giflib.sourceforge.net/"
description="Library for reading and writing gif images."
version=$(sf_ver giflib/code)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://sourceforge.net/projects/giflib/files/$filename"
unpk_enter "$filename" "$direname"
maki PREFIX=/usr DOCDIR=/usr/share/doc/$direname
sudo rm -fv /usr/lib/libgif.a
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
