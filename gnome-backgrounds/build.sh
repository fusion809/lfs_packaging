#!/bin/bash
set -e
name=gnome-backgrounds
repo=GNOME/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(libjxl)
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
