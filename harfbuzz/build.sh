#!/bin/bash
set -e
name=harfbuzz
homepage="https://harfbuzz.github.io/"
description="OpenType text shaping engine"
repo="$name/$name"
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo expat fontconfig freetype gcc glib2 glib2 glibc graphite2 icu libffi libpng libx11 libxau libxcb libxdmcp libxext libxrender pcre2 pixman zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
      --prefix=/usr        \
      --buildtype=release  \
      -D graphite2=enabled)
mni "${meson_options[@]}"
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
