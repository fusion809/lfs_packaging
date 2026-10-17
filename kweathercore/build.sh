#!/bin/bash
set -e
name=kweathercore
repo=KDE/$name
homepage="https://invent.kde.org/libraries/kweathercore"
description="Facilitates retrieval of weather information."
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu keyutils kholidays ki18n mitkrb openssl pcre2 qt6 systemd zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D BUILD_TESTING=OFF -W no-author
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
