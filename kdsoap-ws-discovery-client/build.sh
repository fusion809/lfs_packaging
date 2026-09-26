#!/bin/bash
set -e
name=kdsoap-ws-discovery-client
homepage="https://caspermeijn.gitlab.io/kdsoap-ws-discovery-client/"
description="WS-Discovery client library based on KDSoap"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu kdsoap keyutils mitkrb openssl pcre2 qt6 systemd zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "other" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D QT_MAJOR_VERSION=6           \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
