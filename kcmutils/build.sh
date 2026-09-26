#!/bin/bash
set -e
name=kcmutils
homepage="https://develop.kde.org/products/frameworks/"
description="Utilities for interacting with KCModules"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcodecs kcolorscheme kconfig kconfigwidgets kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kservice kwidgetsaddons kwindowsystem kxmlgui libdrm libelf libffi libpciaccess libpng libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 solid spirv-tools systemd util-linux wayland xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "frameworks" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -D CMAKE_INSTALL_PREFIX=/usr \
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
