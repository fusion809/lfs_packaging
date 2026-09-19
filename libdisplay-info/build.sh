#!/bin/bash
set -e
name=libdisplay-info
repo=emersion/$name
version=$(gfd_ver "$repo")
direname="$name-$version"
filename="$direname.tar.xz"
depends=(glibc hwdata)
gfdr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
