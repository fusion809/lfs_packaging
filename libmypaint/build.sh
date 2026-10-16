#!/bin/bash
set -e
name=libmypaint
repo=mypaint/$name
homepage="https://github.com/mypaint/libmypaint"
description="Library for making brushstrokes which is used by MyPaint and other projects."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
if ! which automake-1.16 &> /dev/null; then
	sudo ln -sf /usr/bin/automake-1.19 /usr/bin/automake-1.16
fi
if ! which aclocal-1.16 &> /dev/null; then
	sudo ln -sf /usr/bin/aclocal-1.19 /usr/bin/aclocal-1.16
fi
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
