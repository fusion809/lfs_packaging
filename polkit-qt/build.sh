#!/bin/bash
set -e
name=polkit-qt
repo=KDE/$name-1
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libdrm libelf libffi libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 polkit qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-1-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D QT_MAJOR_VERSION=6 \
	-W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
