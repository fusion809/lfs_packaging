#!/bin/bash
set -e
name=libndp
homepage="http://libndp.org/"
description="Library for Neighbor Discovery Protocol"
repo=jpirko/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "http://libndp.org/files/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --sysconfdir=/etc --localstatedir=/var
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
