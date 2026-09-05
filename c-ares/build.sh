#!/bin/bash
set -e
name=c-ares
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
