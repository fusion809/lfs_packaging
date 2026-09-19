#!/bin/bash
set -e
name=libgxps
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 cairo expat fontconfig freetype gcc glib2 glibc icu lcms2 libarchive libffi libjpeg-turbo libpng libwebp libX11 libXau libxcb libXdmcp libXext libxml2 libXrender lz4 openssl pcre2 pixman systemd tiff util-linux xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr \
    --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
