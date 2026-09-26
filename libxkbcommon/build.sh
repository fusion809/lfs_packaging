#!/bin/bash
set -e
name=libxkbcommon
homepage="https://xkbcommon.org/"
description="Keymap handling library for toolkits and window systems"
repo=lfs-book/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(libxcb wayland wayland-protocols xkeyboard-config)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
gap_patches $name
meson_options=(--prefix=/usr        \
      --buildtype=release  \
      -D enable-docs=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
