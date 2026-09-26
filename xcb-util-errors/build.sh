#!/bin/bash
set -e
name=xcb-util-errors
homepage="https://cgit.freedesktop.org/xcb/util-errors/"
description="XCB errors library"
version=$(xcb_ver $name)
depends=(glibc libxau libxcb libxdmcp)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
