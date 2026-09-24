#!/bin/bash
set -e
name=knighttime
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kconfig kcoreaddons kdbusaddons kholidays libdrm libelf libffi libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
