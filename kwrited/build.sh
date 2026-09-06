#!/bin/bash
set -e
name=kwrited
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(kconfig kcoreaddons ki18n knotifications kpty libXau libXdmcp libcanberra libdrm libogg libvorbis libxcb llvm lm-sensors qt6 spirv-tools webkitgtk)
lfs_depends=(dbus libelf)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
