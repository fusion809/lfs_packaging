#!/bin/bash
set -e
name=LibrePlayer
repo="Procurador1337/$name"
version=$(gh_com "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 cmake dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz keyutils lame libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 spirv-tools systemd wayland xz zlib zstd)

gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=None
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
