#!/bin/bash
set -e
name=libkdcraw
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu lcms2 libdrm libelf libffi libjpeg-turbo libpciaccess libpng libraw libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
	-D BUILD_TESTING=OFF \
	-D QT_MAJOR_VERSION=6 \
	-W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
