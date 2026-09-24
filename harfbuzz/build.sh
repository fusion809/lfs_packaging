#!/bin/bash
set -e
name=harfbuzz
repo="$name/$name"
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo expat fontconfig freetype gcc glib2 glib2 glibc graphite2 icu libffi libpng libX11 libxau libxcb libXdmcp libXext libXrender pcre2 pixman zlib)
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
