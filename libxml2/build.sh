#!/bin/bash
set -e
name=libxml2
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(gcc glibc icu ncurses readline)
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -i "/'git'/,+3d" meson.build
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D history=enabled  \
      -D icu=enabled)
mni "${meson_options[@]}"
sudo sed "s/--static/--shared/" -i /usr/bin/xml2-config
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
