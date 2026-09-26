#!/bin/bash
set -e
name=bubblewrap
homepage="https://github.com/containers/bubblewrap"
description="Unprivileged sandboxing tool"
repo="containers/$name"
version=$(gh_ver $repo)
depends=(glibc libcap)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# User namespace support is required in the kernel
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
