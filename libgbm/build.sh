#!/bin/bash
set -e
name=libgbm
repo=glfs-book/$name
homepage="https://github.com/glfs-book/libgbm"
# Required by NVIDIA drivers.
description="Provides API functions for managing memory buffers."
version=$(gh_ver $repo)
depends=(glibc libdrm)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
