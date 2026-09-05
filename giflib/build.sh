#!/bin/bash
set -e
name=giflib
version=$(sf_ver giflib/code)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/giflib/files/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
maki PREFIX=/usr DOCDIR=/usr/share/doc/$direname
sudo rm -fv /usr/lib/libgif.a
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
