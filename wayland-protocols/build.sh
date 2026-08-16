#!/bin/bash
name=wayland-protocols
version=$(way_ver $name)
blfs_depends=(wayland)
lfs_depends=(coreutils meson ninja tar wget xz)
filename="$name-$version.tar.xz"
direname="$name-$version"
URL="https://gitlab.freedesktop.org/wayland/$name/-/releases/$version/downloads/$filename"
if ! [[ -f "$filename" ]]; then
	wget -c $URL 
fi

tar xf $filename
cd $direname
meson_options=(
      --prefix=/usr       \
      --buildtype=release
)
mni "${meson_options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
