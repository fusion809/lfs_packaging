#!/bin/bash
set -e
name=libsigcpp2
_name=libsigcplusplus
repo=$_name/$_name
homepage="https://github.com/libsigcplusplus/libsigcplusplus"
description="libsigc++ implements a typesafe callback system for standard C++."
version=$(gh_ver $repo $name)
filename="libsigc++-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(boost gcc glibc libxslt)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i "s/'system',//" meson.build
mni --prefix=/usr --buildtype=release -D maintainer-mode=true -D build-documentation=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
