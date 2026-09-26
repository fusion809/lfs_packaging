#!/bin/bash
set -e
name=plasma-pa
homepage="https://kde.org/plasma-desktop/"
description="Plasma applet for audio volume management using PulseAudio"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcmutils kcolorscheme kconfig kcoreaddons kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kirigami kitemviews knotifications kpackage kstatusnotifieritem ksvg kwindowsystem lame libcanberra libdrm libelf libffi libogg libpciaccess libplasma libpng libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 plasma-activities pulseaudio pulseaudio-qt qt6 spirv-tools systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export PATH=$PATH:/opt/qt6/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/qt6/lib
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
