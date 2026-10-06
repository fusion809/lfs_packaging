#!/bin/bash
set -e
name=qcoro
homepage="https://github.com/danvratil/qcoro"
description="C++ Coroutines for Qt."
repo="danvratil/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon mitkrb openssl pcre2 qt6 systemd zlib zstd)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/opt/qt6 \
      -D CMAKE_BUILD_TYPE=Release     \
      -D BUILD_TESTING=OFF            \
      -D QCORO_BUILD_EXAMPLES=OFF     \
      -D BUILD_SHARED_LIBS=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
