#!/bin/bash
set -e
name=pixman
homepage="https://gitlab.freedesktop.org/pixman/pixman"
description="The pixel-manipulation library for X and cairo"
repo=lib$name/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://www.cairographics.org/releases/$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
