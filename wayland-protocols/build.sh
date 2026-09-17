#!/bin/bash
set -e
name=wayland-protocols
repo=wayland/$name
version=$(way_ver $name)
depends=(coreutils meson ninja tar wayland wget xz)
filename="$name-$version.tar.xz"
direname="$name-$version"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
      --prefix=/usr       \
      --buildtype=release
)
mni "${meson_options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
