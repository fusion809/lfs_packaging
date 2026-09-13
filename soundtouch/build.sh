#!/bin/bash
set -e
name=soundtouch
repo=VinMing/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.surina.net/soundtouch/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
unset ACLOCAL
./bootstrap
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
