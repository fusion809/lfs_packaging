#!/bin/bash
set -e
name=dav1d
repo=videolan/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://code.videolan.org/videolan/dav1d/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mni --prefix=/usr --buildtype=release --wrap-mode=nofallback
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
