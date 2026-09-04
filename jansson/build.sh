#!/bin/bash
set -e
name=jansson
repo="akheron/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
