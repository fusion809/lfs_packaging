#!/bin/bash
set -e
name=xcb-util-renderutil
homepage="https://xcb.freedesktop.org"
description="Utility libraries for XC Binding - Convenience functions for the Render extension"
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
