#!/bin/bash
set -e
name=kcolorpicker
homepage="https://github.com/DamirPorobic/kColorPicker"
description="Qt based Color Picker with popup menu"
_name=kColorPicker
repo=ksnip/$_name
version=$(gh_ver $repo)
depends=(brotli bzip2 cmake dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libdrm libelf libffi libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D BUILD_SHARED_LIBS=ON      \
      -D BUILD_WITH_QT6=ON)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
