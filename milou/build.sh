#!/bin/bash
set -e
name=milou
repo=KDE/$name
version=$(gh_ver $repo)
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcolorscheme kconfig kcoreaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kirigami kitemmodels knotifications kpackage krunner ksvg kwindowsystem libcanberra libdrm libelf libffi libogg libpciaccess libplasma libpng libvorbis libx11 libxau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 plasma-activities qt6 spirv-tools systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
