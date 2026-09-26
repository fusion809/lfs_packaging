#!/bin/bash
set -e
# Variable declarations
name="wl-clipboard"
repo="bugaevc/wl-clipboard"
homepage="https://github.com/$repo"
description="Command-line copy/paste utilities for Wayland"
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash coreutils glibc libffi meson ninja wayland wayland wayland-protocols)
# Fetch and unpack source
gha_download "$repo" "${version}" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
cd ../..
# Cleanup and add to database
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
