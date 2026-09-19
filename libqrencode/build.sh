#!/bin/bash
set -e
name=libqrencode
repo=fukuchi/$name
version=$(gh_ver $repo)
depends=(glibc libpng zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
