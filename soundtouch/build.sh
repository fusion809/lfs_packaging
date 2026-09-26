#!/bin/bash
set -e
name=soundtouch
homepage="https://www.surina.net/soundtouch/"
description="An audio processing library"
repo=VinMing/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.surina.net/soundtouch/$filename"
unpk_enter "$filename" "$name"
unset ACLOCAL
./bootstrap
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
