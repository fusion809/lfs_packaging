#!/bin/bash
set -e
name=LibreNote
repo="Procurador1337/$name"
version=$(gh_com "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 cmake coreutils dbus double-conversion expat fontconfig freetype gcc git glib2 glibc graphite2 harfbuzz libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors make mesa pcre2 qt6 spirv-tools systemd tar wayland xz zlib zstd)

gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
