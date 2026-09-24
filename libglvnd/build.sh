#!/bin/bash
set -e
name=libglvnd
repo=glvnd/libglvnd
version=$(gfd_ver $repo)
depends=(glibc libx11 libxau libxcb libXdmcp)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
gfd_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
mni --prefix=/usr --buildtype=release -D hgl=false
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
