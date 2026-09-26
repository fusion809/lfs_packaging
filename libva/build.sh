#!/bin/bash
set -e
name=libva
homepage="https://intel.github.io/libva/"
description="Video Acceleration (VA) API for Linux"
repo=intel/$name
version=$(gh_ver $repo)
depends=(bzip2 elfutils expat gcc glibc icu libdrm libffi libpciaccess libx11 libxau libxcb libxdmcp libxext libxfixes libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa spirv-tools wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
