#!/bin/bash
set -e
name=gegl
repo=GNOME/$name
homepage="https://gitlab.com/GNOME/gegl"
description="GEneric Graphics Library, which is a graph based image processing format."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
_version=$(echo $version | tr '.' '_')
depends=(babl json-glib glib2 graphviz)
tag=GEGL_${_version}
gha_download "$repo" "$tag" "$filename"
unpk_enter "$filename"
mni --prefix=/usr --buildtype=release
cd ..
direname=$(echo $PWD | rev | cut -d '/' -f 1 | rev)
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
