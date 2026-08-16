#!/bin/bash
set -e
name=LibreNote
version=$(gh_com "Procurador1337/$name")
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa pcre2 wayland)
blfs_depends=(brotli double-conversion fontconfig freetype git graphite2 harfbuzz libXau libXdmcp libdrm libpng libxcb libxkbcommon libxml2 llvm lm-sensors qt6 spirv-tools)
lfs_depends=(bzip2 cmake coreutils dbus expat gcc glibc libelf libffi make systemd xz zlib zstd)
direname=$name

if ! [[ -d $direname/.git ]]; then
	git clone https://github.com/Procurador1337/$name
fi

cd $direname
git stash
git pull origin main
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
