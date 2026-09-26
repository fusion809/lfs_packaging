#!/bin/bash
set -e
name=threadweaver
homepage="https://develop.kde.org/products/frameworks/"
description="High-level multithreading framework"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu keyutils mitkrb openssl pcre2 qt6 systemd zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
            -D CMAKE_INSTALL_LIBEXECDIR=libexec \
            -D CMAKE_PREFIX_PATH=/opt/qt6        \
            -D CMAKE_SKIP_INSTALL_RPATH=ON      \
            -D CMAKE_BUILD_TYPE=Release         \
            -D BUILD_TESTING=OFF                \
            -D BUILD_PYTHON_BINDINGS=OFF        \
	    -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
