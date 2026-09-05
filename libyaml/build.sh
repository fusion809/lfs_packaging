#!/bin/bash
set -e
name=libyaml
repo="yaml/$name"
version=$(gh_ver $repo)
depends=(glibc)
filename="yaml-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
