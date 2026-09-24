#!/bin/bash
set -e
name=libsndfile
repo=$name/$name
version=$(gh_ver $repo)
depends=(alsa-lib brotli bzip2 dbus double-conversion elfutils expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu lame libdrm libffi libogg libpciaccess libpng libvorbis libx11 libxau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mpg123 opus pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i '/typedef enum/,/bool ;/d' src/ALAC/alac_{en,de}coder.c
cmi --prefix=/usr -docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
