#!/bin/bash
set -e
name=swig
description="Generate scripting interfaces to C/C++ code"
homepage="https://www.swig.org"
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc pcre2 zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sf_download "$name" "$direnaem" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo cp -v -R Doc -T /usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
