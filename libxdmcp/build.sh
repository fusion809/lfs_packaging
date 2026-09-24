#!/bin/bash
set -e
_name=libXdmcp
version=$(xfd_ver $_name)
depends=(brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libdrm libffi libpciaccess libpng libx11 libxau libxcb libxext libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
xfd_download "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
