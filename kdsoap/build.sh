#!/bin/bash
set -e
name=kdsoap
homepage="https://github.com/KDAB/KDSoap"
description="Qt-based client-side and server-side SOAP component"
repo=KDAB/KDSoap
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu keyutils mitkrb openssl pcre2 qt6 systemd zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_DOCDIR=/usr/share/doc/$direname)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
