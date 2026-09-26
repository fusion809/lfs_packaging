#!/bin/bash
set -e
name=xcb-proto
homepage="https://xcb.freedesktop.org/"
description="XML-XCB protocol descriptions"
repo=xorg/proto/xcbproto
version=$(gfd_ver $repo $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
PYTHON=python3 cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
