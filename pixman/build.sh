#!/bin/bash
set -e
name=pixman
repo=lib$name/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.cairographics.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
