#!/bin/bash
set -e
name=LibreNote
repo="Procurador1337/$name"
version=$(gh_com "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
blfs_depends=(brotli double-conversion fontconfig freetype git graphite2 harfbuzz libXau libXdmcp libdrm libpng libxcb libxkbcommon libxml2 llvm lm-sensors qt6 spirv-tools glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa pcre2 wayland)
lfs_depends=(bzip2 cmake coreutils dbus expat gcc glibc libelf libffi make systemd xz zlib zstd tar)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
common_cmake_args=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INSTALL_PREFIX=/usr
  -Wno-dev
)
cmaki "${common_cmake_args[@]}"
cd ..
rm -rf build
cd ..
echo "$version" > /var/lib/custom-packages/$name
