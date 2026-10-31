#!/bin/bash
set -e
name=sdl12-compat
repo=libsdl-org/$name
homepage="https://github.com/libsdl-org/sdl12-compat"
description="SDL 1.2 runtime compatibility library using SDL 2.0."
version=$(gh_ver $repo)
filename="$name-release-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(sdl2-compat glu cmake)
gha_download "$repo" "release-$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
