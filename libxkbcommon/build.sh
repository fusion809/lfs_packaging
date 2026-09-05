#!/bin/bash
set -e
name=libxkbcommon
repo=lfs-book/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(xkeyboard-config libxcb wayland wayland-protocols)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/lfs-book/libxkbcommon/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
meson_options=(--prefix=/usr        \
      --buildtype=release  \
      -D enable-docs=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
