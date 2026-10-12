#!/bin/bash
set -e
name=bdwgc
repo=$name/$name
homepage="https://github.com/bdwgc/bdwgc/wiki"
description="The Boehm-Demers-Weiser conservative C/C++ Garbage Collector."
version=$(gh_ver $repo)
depends=(glibc)
filename="gc-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
