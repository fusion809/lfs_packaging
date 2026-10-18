#!/bin/bash
set -e
name=eigen
repo=lib$name/$name
homepage="https://gitlab.com/libeigen/eigen"
description="Lightweight C++ template library for vector and matrix maths."
version=$(gl_ver $repo)
depends=(gcc glibc zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gla_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
