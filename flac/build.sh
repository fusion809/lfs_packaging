#!/bin/bash
set -e
name=flac
repo=xiph/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
blfs_depends=(libogg)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr            \
            --disable-thorough-tests \
	    --docdir=/usr/share/doc/$direname)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
