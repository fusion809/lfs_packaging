#!/bin/bash
set -e
name=pulseaudio-qt
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu lame libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mpg123 opus pcre2 pulseaudio qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "other" "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_PREFIX_PATH=/opt/qt6 -D CMAKE_SKIP_INSTALL_RPATH=ON  -D CMAKE_BUILD_TYPE=Release               -D BUILD_TESTING=OFF)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
