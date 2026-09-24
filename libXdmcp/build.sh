#!/bin/bash
set -e
name=libXdmcp
version=$(xfd_ver $name)
depends=(brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libdrm libffi libpciaccess libpng libx11 libxau libxcb libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
