#!/bin/bash
set -e
name=kweather
repo=KDE/$name
homepage="https://invent.kde.org/utilities/kweather"
description="Weather application for Plasma."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcolorscheme kconfig kcoreaddons kcrash keyutils kglobalaccel kguiaddons kholidays ki18n kiconthemes kirigami kitemmodels knotifications kpackage krunner ksvg kweathercore kwindowsystem libcanberra libffi libglvnd libogg libplasma libpng libtool libvorbis libx11 libxau libxcb libxdmcp libxfixes libxkbcommon mitkrb openssl pcre2 plasma-activities qt6 systemd util-linux wayland xcb-util-keysyms xz zlib zstd)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -DCMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D BUILD_TESTING=OFF -W no-author
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
