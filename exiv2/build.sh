#!/bin/bash
set -e
name=exiv2
homepage="https://exiv2.org"
description="Exif, Iptc and XMP metadata manipulation library and tools"
repo="Exiv2/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(brotli cmake curl curl cyrus-sasl expat gcc glibc inih libidn2 libpsl libunistring nghttp2 openldap openssl zlib zstd)
gha_download $repo $version $filename
unpk_enter "$filename" "$direname"
cmake_options=(
      -D CMAKE_INSTALL_PREFIX=/usr   \
      -D CMAKE_BUILD_TYPE=Release    \
      -D EXIV2_ENABLE_VIDEO=yes      \
      -D EXIV2_ENABLE_WEBREADY=yes   \
      -D EXIV2_ENABLE_CURL=yes       \
      -D EXIV2_BUILD_SAMPLES=no      \
      -D CMAKE_SKIP_INSTALL_RPATH=ON \
      -G Ninja
)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
