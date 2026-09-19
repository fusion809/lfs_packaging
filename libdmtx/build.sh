#!/bin/bash
# Included because it's required by prison-6.24.0 of kframeworks
set -e
name=libdmtx
repo="dmtx/libdmtx"
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(glibc)
gha_download "$repo" "v${version}" "$filename"
unpk_enter "$filename" "$direname"
sudo autoreconf -vi
sudo chown $USER -R .
cmi --prefix=/usr
cd ..
sudo rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
