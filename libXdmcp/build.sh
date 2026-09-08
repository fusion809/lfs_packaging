#!/bin/bash
set -e
name=libXdmcp
version=$(xfd_ver $name)
depends=(brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa pcre2 systemd wayland xz zlib zstd)
blfs_depends=(libXau libdrm libxcb llvm lm-sensors qt6 spirv-tools)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.x.org/pub/individual/lib/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
