#!/bin/bash
set -e
name=libsndfile
repo=$name/$name
version=$(gh_ver $repo)
depends=(alsa-lib brotli bzip2 dbus double-conversion elfutils expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu lame libX11 libXau libXdmcp libXext libXxf86vm libffi libogg libpciaccess libpng libxcb libxkbcommon libxml2 libxshmfence lm-sensors mesa mpg123 pcre2 qt6 systemd wayland xz zlib zstd)
blfs_depends=(libdrm libvorbis llvm opus spirv-tools)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/typedef enum/,/bool ;/d' src/ALAC/alac_{en,de}coder.c
cmi --prefix=/usr -docdir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
