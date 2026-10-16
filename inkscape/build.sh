#!/bin/bash
set -e
name=inkscape
repo=$name/$name
homepage="https://inkscape.org"
description="Open-source vector graphics editing software."
version=$(gl_ver $repo)
depends=(gsl gtkmm3 bdwgc double-conversion boost libxslt poppler popt imagemagick lcms2 potrace libcanberra)
_version=$(echo $version | tr '.' '_')
tag="INKSCAPE_$_version"
filename="$name-$tag.tar.bz2"
direname="${filename/.tar.*/}"
gla_download "$repo" "$tag" "$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D WITH_INTERNAL_2GEOM=ON    \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
