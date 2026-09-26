#!/bin/bash
set -e
name=gnome-user-docs
homepage="https://gitlab.gnome.org/GNOME/gnome-user-docs"
description="User documentation for GNOME"
repo=GNOME/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(yelp-tools)
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
