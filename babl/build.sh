#!/bin/bash
set -e
name=babl
repo=GNOME/$name
homepage="https://gitlab.gnome.org/GNOME/babl/"
description="Dynamic, any to any, pixel format translation library."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
_version=$(echo $version | tr '.' '_')
tag=BABL_$_version
gha_download "$repo" "$tag" "$filename"
unpk_enter "$filename"
mni --prefix=/usr --buildtype=release
sudo su -c "install -v -m755 -d                            /usr/share/gtk-doc/html/babl/graphics &&
install -v -m644 ../docs/*.{css,html}          /usr/share/gtk-doc/html/babl          &&
install -v -m644 ../docs/graphics/*.{html,svg} /usr/share/gtk-doc/html/babl/graphics"
cd ..
direname=$(echo $PWD | sed 's|.*/||g')
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
