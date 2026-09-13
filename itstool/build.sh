#!/bin/bash
set -e
name=itstool
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
PYTHON=/usr/bin/python3 ./autogen.sh --prefix=/usr
maki
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
