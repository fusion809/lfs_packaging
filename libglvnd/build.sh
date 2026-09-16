#!/bin/bash
set -e
name=libglvnd
repo=glvnd/libglvnd
version=$(gfd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/$repo/-/archive/v$version/$filename
fi
sudo rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
mni --prefix=/usr --buildtype=release -D hgl=false
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
