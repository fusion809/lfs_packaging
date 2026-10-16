#!/bin/bash
set -e
name=inkscape
repo=$name/$name
homepage="https://inkscape.org"
description="Open-source vector graphics editing software."
version=$(gl_ver $repo)
depends=(gsl gtkmm3 bdwgc double-conversion boost libxslt poppler popt imagemagick lcms2 potrace libcanberra)
_version=$(echo $version | tr '.' '_')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
_direname=$(wget -cqO- $homepage/release/$direname/source/archive/xz/dl/ | 
grep "href=\"https://media.inkscape.*$version_.*.tar.xz" -oE | rev | 
cut -d '/' -f 1 | rev | sed 's/.tar.xz//g')
src=$homepage/$(wget -cqO- $homepage/release/$direname/source/archive/xz/dl/ | 
grep "href.*$version.tar.xz" | cut -d '"' -f 2)
download_src "$src"
unpk_enter "$filename"
gap_patches "$name"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D WITH_INTERNAL_2GEOM=ON    \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$_direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
