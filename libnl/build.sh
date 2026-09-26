#!/bin/bash
set -e
name=libnl
homepage="https://github.com/thom311/libnl/"
description="Library for applications dealing with netlink sockets"
repo=thom311/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel config options required
ghr_download "$repo" "libnl$(echo $version | sed -E 's/\./_/g')" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --sysconfdir=/etc --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
