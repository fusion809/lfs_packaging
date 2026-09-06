#!/bin/bash
set -e
name=ksvg
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcolorscheme kconfig kcoreaddons keyutils kguiaddons ki18n kirigami libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa mitkrb openssl pcre2 systemd util-linux wayland xz zlib zstd)
lfs_depends=(dbus libelf)
blfs_depends=(libXau libXdmcp libdrm libxcb llvm lm-sensors qt6 spirv-tools)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/frameworks/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
camke_options=(-D CMAKE_INSTALL_PREFIX=/usr \
            -D CMAKE_INSTALL_LIBEXECDIR=libexec \
            -D CMAKE_PREFIX_PATH=/opt/qt6        \
            -D CMAKE_SKIP_INSTALL_RPATH=ON      \
            -D CMAKE_BUILD_TYPE=Release         \
            -D BUILD_TESTING=OFF                \
            -D BUILD_PYTHON_BINDINGS=OFF        \
	    -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
