#!/bin/bash
set -e
name=libyaml
homepage="https://pyyaml.org/wiki/LibYAML"
description="YAML 1.1 library"
repo="yaml/$name"
version=$(gh_ver $repo)
depends=(glibc)
filename="yaml-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
