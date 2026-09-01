#!/bin/bash
set -e
name=LibrePlayer
repo="Procurador1337/$name"
version=$(gh_com "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(brotli cmake double-conversion flac fontconfig freetype graphite2 harfbuzz keyutils lame libXau libXdmcp libdrm libogg libpng libsndfile libvorbis libxcb libxkbcommon libxml2 llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools)
lfs_depends=(bzip2 dbus e2fsprogs expat gcc glibc libelf libffi openssl systemd xz zlib zstd)
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa mitkrb pcre2 wayland)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=None
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
