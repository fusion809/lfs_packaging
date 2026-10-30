#!/bin/bash
set -e
name=nanosvg-git
_name=nanosvg
repo=memononen/$_name
homepage="https://github.com/memononen/nanosvg"
description="Simple stupid SVG parser."
version=$(gh_com $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
#wget -c \
#    https://github.com/fltk/nanosvg/commit/abcd277ea45e9098bed752cf9c6875b533c0892f.patch \
#    -O fltk.patch

#patch --dry-run -Np1 -i fltk.patch
#patch -Np1 -i fltk.patch
cmake_options=(-DCMAKE_BUILD_TYPE='None' \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DBUILD_SHARED_LIBS=ON \
	-Wno-dev)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
