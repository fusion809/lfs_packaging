#!/bin/bash
set -e
name=xdg-user-dirs
repo=xdg/$name
description="Manage user directories like ~/Desktop and ~/Music."
homepage="https://www.freedesktop.org/wiki/Software/xdg-user-dirs"
version=$(gfd_ver $repo)
filename="$name-v$version.tar.gz"
direname="${filename/.tar.*/}"
gfd_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D docs=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
