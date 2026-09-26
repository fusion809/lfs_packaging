#!/bin/bash
set -e
_name=LibreWeather
name=libreweather
repo=Procurador1337/$_name
version=$(gh_com "$repo")
depends=(brotli cmake coreutils dbus double-conversion e2fsprogs expat gcc glib2 glibc keyutils libelf libffi make mitkrb openssl pcre2 qt6 systemd zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ../..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee /var/lib/custom-packages/$name
